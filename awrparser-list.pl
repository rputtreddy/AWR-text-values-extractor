use strict;
use File::Glob;

my @files = <"D:\\Projects\\Kotal Life Insurance\\30DaysLogs\\Fourdx DB\\AWR\\awr for FourDX 22nd May\\*.html">;
my $destFileName = "D:\\Projects\\Kotal Life Insurance\\30DaysLogs\\Fourdx DB\\AWR\\awr for FourDX 22nd May";

my $startTimestamp;
my $endTimestamp;
my $beginSnapId;
my $endSnapId;
my @tempInstanceActivityStats;
my @tempStats;
my @instanceActivityStats;
my $flag;
my $startInstantActivity = "<table border=\"1\" summary=\"This table displays Instance activity statistics";
my $endInstantActivity = "<\/table><p \/>";
my $startForegroundWaitClassStats = "<table border=\"1\" summary=\"This table displays foreground wait class statistics\">";
my $endForegroundWaitClassStats="<\/table><p \/>";
my $startForegroundWaitEventStats = "<table border=\"1\" summary=\"This table displays Foreground Wait Events and their wait statistics\">";
my $endForegroundWaitEventStats = "<\/table><p \/>";

sub readLines(){
my $fh = shift;
$flag = 0;
# To fetch Instance activity statistics #
while(my $line = <$fh>){
         if($line =~ /End Snap:/){
              $line =~ s/<td scope="row" class='awrc'>/^/g;
              $line =~ s/<td align="right" class='awrc'>/^/g;
              $line =~ s/<td align="center" class='awrc'>/^/g;
              $line =~ s/<tr>\^//g;
              $line =~ s/<\/tr>//g;
              $line =~ s/<\/td>//g;
              my @temp = split /\^/,$line;
   			  $endSnapId = $temp[1];
              $endTimestamp = $temp[2];
            }
          if($line =~ /Begin Snap:/){
			  $line =~ s/<td scope="row" class='awrnc'>/^/g;
              $line =~ s/<td align="right" class='awrnc'>/^/g;
              $line =~ s/<td align="center" class='awrnc'>/^/g;
              $line =~ s/<tr>\^//g;
              $line =~ s/<\/tr>//g;
              $line =~ s/<\/td>//g;
              my @temp = split /\^/,$line;
   			  $beginSnapId = $temp[1];
              $startTimestamp = $temp[2];	          	
          }  
              
       if ($line =~ /$startForegroundWaitEventStats/){
             $line = join('^',$startTimestamp,$endTimestamp,$beginSnapId,$endSnapId,$line);
             push(@tempInstanceActivityStats,$line);
             $flag = 1;
       }
       elsif($flag){
             $line = join('^',$startTimestamp,$endTimestamp,$beginSnapId,$endSnapId,$line);
             push(@tempInstanceActivityStats,$line);
             $flag = 1;
             last if($line =~ /$endForegroundWaitEventStats/);
        }
       }
return @tempInstanceActivityStats;
}

sub removeUnwantedLines(){
            my @strLines = @_;
            my @tempStr;
            foreach(@strLines){       
            next if $_ =~ /$startForegroundWaitEventStats/;
            next if $_ =~ /$endForegroundWaitEventStats/;
                        $_ =~ s/<td scope="row" class='awrc'>/^/g;
                        $_ =~ s/<td scope="row" class='awrnc'>/^/g;
                        $_ =~ s/<td align="right" class='awrc'>/^/g;
                        $_ =~ s/<td align="right" class='awrnc'>/^/g;
                        $_ =~ s/<td class='awrc'>/^/g;
                        $_ =~ s/<td class='awrnc'>/^/g;
                        $_ =~ s/<tr>\^//g;
                        $_ =~ s/<td>//g;
                        $_ =~ s/,//g;
                        $_ =~ s/;//g;
                        $_ =~ s/<\/td>//g;
                        $_ =~ s/<\/tr>//g;
                        $_ =~ s/&#160//g;
                        push(@tempStr, $_);
            }
            return @tempStr;
}

sub nullifyArrays(){
       my @temp = @_;
       return @temp=();
}

sub writeToFile(){
       my @temp = @_;
       open my $fh, ">$destFileName\\ForegroundWaitEvents.csv" || die "$destFileName\\ForegroundWaitEvents.csv unable to write into file";
       #open my $fh, ">$destFileName\\ForegroundWaitClass.csv" || die "$destFileName\\ForegroundWaitClass.csv unable to write into file";
       #open my $fh, ">$destFileName\\InstanceActivityStats.csv" || die "$destFileName\\InstanceActivityStats.csv unable to write into file";
       #print $fh "Timestamp,EndTimestamp,BeginSnap,EndSnap,Static Name, Total, PerSecond, PerTransaction\n";
       #print $fh "Timestamp,EndTimestamp,BeginSnap,EndSnap,WaitClass,Waits,%Time-outs,TotalWaitTime,AvgWait(ms),%DBTime\n";
       print $fh "Timestamp,EndTimestamp,BeginSnap,EndSnap,Event,Waits,%Time-outs,TotalWaitTimeInSec,AvgWaitMsec,WaitsPerTxn,%DBTime\n";
       print $fh @temp;
       close($fh);
}

my $start_time = time();

foreach my $fh(@files){
        #print "Reading file $fh \n";
        open my $FILE, "<$fh" || die "$fh not found";
        @tempStats = &readLines($FILE);
        close($FILE);
        @instanceActivityStats = &removeUnwantedLines(@tempStats);
        &writeToFile(@instanceActivityStats);
		&nullifyArrays(@tempStats);
		&nullifyArrays(@tempInstanceActivityStats);
#      print "Completed reading file $fh \n";
}

my $end_time = time();
my $run_time = $end_time - $start_time; 
print "Completed task in $run_time seconds \n";
