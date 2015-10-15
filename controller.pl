use CGI;
use DBI;
use LWP::Simple;

my $url = "https://api.bitcoinaverage.com/ticker/USD/last";

my $dbhost = $ENV{"OPENSHIFT_MYSQL_DB_HOST"};
my $dbport = $ENV{"OPENSHIFT_MYSQL_DB_PORT"};
my $dbuser = $ENV{"OPENSHIFT_MYSQL_DB_USERNAME"};
my $dbpw = $ENV{"OPENSHIFT_MYSQL_DB_PASSWORD"};
$dsn = "DBI:mysql:database=bitcoin;host=$dbhost;port=$dbport";
$dbh = DBI->connect($dsn, $dbuser, $dbpw);

for(1..800){
    $dbh->do("CREATE TABLE IF NOT EXISTS randbot (time BIGINT(20), value DOUBLE)");
    $dbh->do("CREATE TABLE IF NOT EXISTS BTC (time BIGINT(20), value DOUBLE)");
    $btc = 0.5;
    $usd = 1-$btc;
    $btcn = `perl randbot.pl`;
    $usdn = 1-$btcn;
    if($btcn > $btc){
        $btcn -= 0.02($btcn - $btc);
    }
    elsif($usdn > $usd){
        $usdn -= 0.02($usdn - $usd);
    }
    my $content = get($url);
    $dbh->do("INSERT INTO BTC VALUES (?, ?)", undef, time, $content);
    sleep(20);
}


$dbh->disconnect();
