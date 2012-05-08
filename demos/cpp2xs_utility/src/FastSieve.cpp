/* This code copied from David Oswald's FastSieve.pm (Math-Prime-FastSieve-0.07)
 * "Sieve" class renamed to "_Sieve" to accommodate --write_export_ok_all option
 */

#include <vector>
using namespace std;

/* Class _Sieve below.  Perl sees it as a class named
 * "Math::Prime::FastSieve::Sieve".  The constructor is mapped to
 * "new()" within Perl, and the destructor to "DESTROY()".  All other
 * methods are mapped with the same name as declared in the class.
 *
 * Therefore, Perl sees this class approximately like this:
 *
 * package Math::Prime::FastSieve;
 *
 * sub new {
 *     my $class = shift;
 *     my $n     = shift;
 *     my $self = bless {}, $class;
 *     $self->{max_n} = n;
 *     $self->{num_primes} = 0;
 *     # Build the sieve here...
 *     # I won't bother translating it to Perl.
 *     $self->{sieve} = $primes;  // A reference to a bit vector.
 *     return $self;
 *  }
 *
 */


class _Sieve
{
    public:
        _Sieve ( int n ); // Constructor. Perl sees "new()".
        ~_Sieve(       ); // Destructor. Seen as "DESTROY()".
        bool isprime( int n ); // Test if n is prime.
        SV*  primes ( int n ); // Return all primes in an aref.
        unsigned int  nearest_le ( int n ); // Return nearest prime <= n.
        unsigned int  nearest_ge ( int n ); // Return nearest prime >= n.
        unsigned int  nth_prime  ( int n ); // Return the nth prime.
        unsigned int  count_sieve(       ); // Retrn count of primes in sieve.
        unsigned int  count_le   ( int n ); // Return number of primes <= n.
        SV*  ranged_primes( int lower, int upper );
                  // Return all primes where "lower <= primes <= upper".
    private:
        std::vector<bool>::size_type    max_n;
        unsigned int                    num_primes;
        vector<bool>* sieve;
};


// Set up a primes sieve of 0 .. n inclusive.
_Sieve::_Sieve( int n )
{
    std::vector<bool>* primes = new std::vector<bool>( n + 1, 0 );
    num_primes = 0;
    if( n < 0 ) // Trap negative n's before we start wielding unsigned ints.
        max_n = 0;
    else
    {
        max_n      = n;
        for( std::vector<bool>::size_type i = 3; i * i <= n; i+=2 )
            if( ! (*primes)[i] )
                for( std::vector<bool>::size_type k, j=i; (k=i*j) <= n; j++ )
                    (*primes)[k] = 1;
    }
    sieve = primes;
}


// Deallocate memory for primes sieve.
_Sieve::~_Sieve() {
    delete sieve;
}


// Yes or no: Is the number a prime?  Must be within the range of
// 0 through max_n (the upper limit set by the constructor).
bool _Sieve::isprime( int n )
{
    if( n < 2 || n > max_n )  return false; // Bounds checking.
    if( n == 2 )              return true;  // 2 is prime.
    if( ! ( n % 2 ) )         return false; // No other evens are prime.
    if( ! ( (*sieve)[n] ) )   return true;  // 0 bit signifies prime.
    return false;                           // default: not prime.
}


// Return a reference to an array containing the list of all primes
// less than or equal to n.  n must be within the range set in the
// constructor.
SV* _Sieve::primes( int n )
{
    AV* av = newAV();
    if( n < 2 || n > max_n ) // Logical short circuit order is significant
                             // since we're about to wield unsigned ints.
        return newRV_noinc( (SV*) av );
    av_push( av, newSVuv( 2U ) );
    num_primes = 1; // Count 2; it's prime.
    for( std::vector<bool>::size_type i = 3; i <= n; i += 2 )
        if( ! (*sieve)[i] )
            av_push( av, newSVuv( i ) );
    return newRV_noinc( (SV*) av );
}

SV* _Sieve::ranged_primes( int lower, int upper )
{
    AV* av = newAV();
    if(
        upper > max_n ||        // upper exceeds upper bound.
        lower > max_n ||        // lower exceeds upper bound.
        upper < 2     ||        // No possible primes.
        lower < 0     ||        // lower underruns bounds.
        lower > upper ||        // zero-width range.
        ( lower == upper && lower > 2 && !( lower % 2 ) ) // Even.
    )
        return newRV_noinc( (SV*) av );  // No primes possible.
    if( lower <= 2 && upper >= 2 )
        av_push( av, newSVuv( 2U ) );    // Lower limit needs to be odd
    if( lower < 3 ) lower = 3;           // Lower limit cannot < 3.
    if( ( upper - lower ) > 0 && ! ( lower % 2 ) ) lower++;
    for( std::vector<bool>::size_type i = lower; i <= upper; i += 2 )
        if( ! (*sieve)[i] )
            av_push( av, newSVuv( i ) );
    return newRV_noinc( (SV*) av );
}


// Find the nearest prime less than or equal to n.  Very fast.
unsigned int _Sieve::nearest_le( int n )
{
    // Remember that order of testing is significant; we have to
    // disqualify negative numbers before we do comparisons against
    // unsigned ints.
    if( n < 2 || n > max_n ) return 0; // Bounds checking.
    if( n == 2 ) return 2U;            // 2 is the only even prime.
    if( ! ( n % 2 ) ) n--;             // Result has to be odd.
    std::vector<bool>::size_type n_index = n;
    while( n_index > 2 )
    {
        if( ! (*sieve)[n_index] ) return n_index;
        n_index -= 2;  // Only test odds.
    }
    return 0; // We should never get here.
}


// Find the nearest prime greater than or equal to n.  Very fast.
unsigned int _Sieve::nearest_ge( int n )
{
    // Order of bounds tests IS significant.
    // Because max_n is unsigned, testing "n > max_n" for values where
    // n is negative results in n being treated as a real big unsigned value.
    // Thus we MUST handle negatives before testing max_n.
    if( n <= 2 ) return 2U;              // 2 is only even prime.
    if( n > max_n ) return 0U;           // Bounds checking.
    std::vector<bool>::size_type n_idx = n;
    if( ! ( n_idx % 2 ) ) n_idx++;              // Start with an odd number.
    while( n_idx <= max_n )
    {
        if( ! (*sieve)[n_idx] ) return n_idx;
        n_idx+=2; // Only test odds.
    }
    return 0U;   // We've run out of sieve to test.
}


// Since we're only storing the sieve (not the primes list), this is a
// linear time operation: O(n).
unsigned int _Sieve::nth_prime( int n )
{
    if( n <  1     ) return 0; // Why would anyone want the 0th prime?
    if( n >  max_n ) return 0; // There can't be more primes than sieve.
    if( n == 1     ) return 2; // We have to handle the only even prime.
    unsigned int count = 1;
    for( std::vector<bool>::size_type i = 3; i <= max_n; i += 2 )
    {
        if( ! (* sieve)[i] ) count++;
        if( count == n ) return i;
    }
    return 0;
}


// Return the number of primes in the sieve.  Once results are
// calculated, they're cached.  First time through is O(n).
unsigned int _Sieve::count_sieve ()
{
    if( num_primes > 0 ) return num_primes;
    num_primes = this->count_le( max_n );
    return num_primes;
}


// Return the number of primes less than or equal to n.  If n == max_n
// the data member num_primes will be set.
unsigned int _Sieve::count_le( int n )
{
    if( n <= 1 || n > max_n ) return 0;
    unsigned int count = 1;      // 2 is prime. Count it.
    for( std::vector<bool>::size_type i = 3; i <= n; i+=2 )
        if( !(*sieve)[i] ) count++;
    if( n == max_n && num_primes == 0 ) num_primes = count;
    return count;
}


// ---------------- For export: Not part of _Sieve class ----------------

/* Sieve of Eratosthenes.  Return a reference to an array containing all
 * prime numbers less than or equal to search_to.
 */


SV* primes( int search_to )
{
    AV* av = newAV();
    if( search_to < 2 )
        return newRV_noinc( (SV*) av ); // Return an empty list ref.
    av_push( av, newSVuv( 2U ) );
    std::vector<bool> primes( search_to + 1, 0 );
    for( std::vector<bool>::size_type i = 3; i * i <= search_to; i+=2 )
        if( ! primes[i] )
            for
            (
                    std::vector<bool>::size_type k, j = i;
                    ( k = i * j ) <= search_to;
                    j++
            )
                primes[ k ] = 1;
    for( std::vector<bool>::size_type i = 3; i <= search_to; i+=2 )
        if( ! primes[i] )
            av_push( av, newSVuv( static_cast<unsigned int>( i ) ) );
    return newRV_noinc( (SV*) av );
}



