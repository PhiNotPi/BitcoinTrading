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

for(1..6){
    $dbh->do("CREATE TABLE IF NOT EXISTS randbot (time BIGINT(20), value DOUBLE)");
    $dbh->do("CREATE TABLE IF NOT EXISTS BTC (time BIGINT(20), stake DOUBLE, score DOUBLE, product DOUBLE)");
    
    my $sth = $dbh->prepare("SELECT * FROM randbot ORDER BY time DESC LIMIT 1");
    $sth->execute();
    $btc = 0;
    $oldproduct = 1;
    if($ref = $sth->fetchrow_hashref())
    {
        $btc = $ref->{'stake'};
        $oldproduct = $ref->{'product'};
    }
    $sth->finish();
    
    $usd = 1-$btc;
    $btcn = `perl randbot.pl $btc`;
    $usdn = 1-$btcn;
    if($btcn > $btc){
        $btcn -= 0.002($btcn - $btc);
    }
    elsif($usdn > $usd){
        $usdn -= 0.002($usdn - $usd);
    }
    
    my $newprice = get($url);
    $sth = $dbh->prepare("SELECT * FROM BTC ORDER BY time DESC LIMIT 1");
    $sth->execute();
    $oldprice = $newprice;
    if($ref = $sth->fetchrow_hashref())
    {
        $oldprice = $ref->{'value'};
    }
    $sth->finish();
    $btcn *= $newprice/$oldprice;
    $score = $btcn + $usdn;
    $btc = $btcn/$score;
    $usd = $usdn/$score;
    $time = time;
    $dbh->do("INSERT INTO BTC VALUES (?, ?)", undef, $time, $newprice);
    $dbh->do("INSERT INTO BTC VALUES (?, ?, ?, ?)", undef, $time, $btc, $score, $oldproduct*$score);
    sleep(20);
}


$dbh->disconnect();
