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

for(1..20){
    $dbh->do("CREATE TABLE IF NOT EXISTS BTC (time BIGINT(20), value DOUBLE)");
    my $content = get($url);
    $dbh->do("INSERT INTO BTC VALUES (?, ?)", undef, time, $content);
    sleep(20);
}


$dbh->disconnect();
