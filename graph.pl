use CGI;
use DBI;
use LWP::Simple;

my $dbhost = $ENV{"OPENSHIFT_MYSQL_DB_HOST"};
my $dbport = $ENV{"OPENSHIFT_MYSQL_DB_PORT"};
my $dbuser = $ENV{"OPENSHIFT_MYSQL_DB_USERNAME"};
my $dbpw = $ENV{"OPENSHIFT_MYSQL_DB_PASSWORD"};
$dsn = "DBI:mysql:database=bitcoin;host=$dbhost;port=$dbport";
$dbh = DBI->connect($dsn, $dbuser, $dbpw);
$dbh->do("CREATE TABLE IF NOT EXISTS BTC (time BIGINT(20), value DOUBLE)");

$datastring = '[';
$datastring .= '{name:"'.$name.'",data:[';
$name = "BTC";

my $sth = $dbh->prepare("SELECT * FROM BTC");
$sth->execute();
while (my $ref = $sth->fetchrow_hashref()) {
    if($ref->{'value'} ne ""){
        $datastring .= "[".(1000 * ($ref->{'time'})).",$ref->{'value'}],";
    }
}
$sth->finish();
$datastring =~ s/,$//;
$datastring .= ']}';
$datastring .= ']';
#$datastring = '[{name:"test",data:[[1443705651000,4],[1444705653000,5],[1445705656000,4.7]]}]';

$dbh->disconnect();
my $q = CGI->new();
print $q->header(), $q->start_html(-style=>"indexstyle.css");
print<<EOF

<script src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min.js"></script>
<script src="https://code.highcharts.com/stock/highstock.js"></script>
<script src="https://code.highcharts.com/stock/modules/exporting.js"></script>
<div id="container" style="height: 400px; min-width: 310px"></div>
<script>

\$(function () {
    var seriesOptions = $datastring;
        // create the chart when all data is loaded
        createChart = function () {

            \$("#container").highcharts('StockChart', {

                rangeSelector: {
                    selected: 4
                },

                yAxis: {
                    labels: {
                        formatter: function () {
                            return (this.value > 0 ? ' + ' : '') + this.value + '%';
                        }
                    },
                    plotLines: [{
                        value: 0,
                        width: 2,
                        color: 'silver'
                    }]
                },

                plotOptions: {
                    series: {
                        compare: 'percent'
                    }
                },

                tooltip: {
                    pointFormat: '<span style="color:{series.color}">{series.name}</span>: <b>{point.y}</b> ({point.change}%)<br/>',
                    valueDecimals: 2
                },

                series: seriesOptions
            });
        };

    
    createChart();
});

</script>
    

EOF
;

print $q->end_html();
