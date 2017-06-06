use strict;
use File::Glob;

my @files = <"filepath\\*.html">;
my $destFileName = "destinationfilepath\\output.csv";

my $startTimestamp;
my $endTimestamp;
my $beginSnapId;
my $endSnapId;
my @tempInstanceActivityStats;
my @tempStats;
my @instanceActivityStats;
my $flag;
my $startSQLTopElapsedTime = "<table border=\"1\" summary=\"This table displays top SQL by elapsed time\"";
my $endSQLTopElapsedTime ="<\/table><p \/>";
my $startSQLTopCPUTime = "<table border=\"1\" summary=\"This table displays top SQL by CPU time\"";
my $startSQLUserIOTime = "<table border=\"1\" summary=\"This table displays top SQL by user I/O time\"";
#my $startSQLPhysicalReads = "<table border=\"1\" summary=\"This table displays top SQL by physical reads\""; 


sub readLines(){
my $fh = shift;
$flag = 0;
#To fetch Instance activity statistics #
while(my $line = <$fh>){
	next if $line =~ /^<td class='awrc'>/;
	next if $line =~ /^<td class='awrnc'>/;
	next if $line =~ /^<\/td>/;
	next if $line =~ /^[A-Za-z0-9._]+/;
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
              
       if ($line =~ /$startSQLTopElapsedTime/){
       		 $line =~ s/^ *$//g;
       		 $line =~ s/^\s+\*$//g;
             $line = join('^',$startTimestamp,$endTimestamp,$beginSnapId,$endSnapId,$line);
             push(@tempInstanceActivityStats,$line);
             $flag = 1;
       }
       elsif($flag){
             $line = join('^',$startTimestamp,$endTimestamp,$beginSnapId,$endSnapId,$line);
             push(@tempInstanceActivityStats,$line);
             $flag = 1;
             last if($line =~ /$endSQLTopElapsedTime/);
        }
       }
return @tempInstanceActivityStats;
}

sub removeUnwantedLines(){
            my @strLines = @_;
            my @tempStr;
            foreach(@strLines){       
            next if $_ =~ /$startSQLTopElapsedTime/;
            next if $_ =~ /$endSQLTopElapsedTime/;
            			$_ =~ s/<tr><td align="right" class='awrc'>//g;
            			$_ =~ s/<tr><td align="right" class='awrnc'>//g;
            			$_ =~ s/<td align="right" class='awrc'>/^/g;
                        $_ =~ s/<td align="right" class='awrnc'>/^/g;
                        $_ =~ s/<td scope="row" class='awrc'>/^/g;
                        $_ =~ s/<td scope="row" class='awrnc'>/^/g;
                        $_ =~ s/<a class="awr" href="#[a-z0-9]+">//g;
						$_ =~ s/<a class="awr" href="#[a-z0-9]+">//g;
						$_ =~ s/<\/a><\/td>//g;	        
                        $_ =~ s/<tr>\^//g;
                        $_ =~ s/<td>//g;
                        $_ =~ s/<\/a>//g;
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
       #open my $fh, ">$destFileName\\SQLTopElapsedTime.csv" || die "$destFileName\\SQLTopElapsedTime.csv unable to write into file";
       #open my $fh, ">$destFileName\\SQLCPUTime.csv" || die "$destFileName\\SQLCPUTime.csv unable to write into file";
       #open my $fh, ">$destFileName\\SQLUserIOWaitTime.csv" || die "$destFileName\\SQLUserIOWaitTime.csv unable to write into file";
       open my $fh, ">$destFileName\\SQLPhysicalReads.csv" || die "$destFileName\\SQLPhysicalReads.csv unable to write into file";
       #print $fh "Timestamp^EndTimestamp^BeginSnap^EndSnap^TotalElapsedTimeSec^Executions^ElapsedTimePerExecutionSec^PercentageTotal^PercentageCPU^PercentageIO^SQLID\n";
       #print $fh "Timestamp^EndTimestamp^BeginSnap^EndSnap^TotalCPUTimeSec^Executions^CPUTimePerExecutionSec^PercentageTotal^TotalElapsedTimeSec^PercentageCPU^PercentageIO^SQLID\n";
       #print $fh "Timestamp^EndTimestamp^BeginSnap^EndSnap^TotalUserIOTimeSec^Executions^UIOTimePerExecutionSec^PercentageTotal^TotalElapsedTimeSec^PercentageCPU^PercentageIO^SQLID\n";
       print $fh "Timestamp^EndTimestamp^BeginSnap^EndSnap^TotalUserIOTimeSec^Executions^UIOTimePerExecutionSec^PercentageTotal^TotalElapsedTimeSec^PercentageCPU^PercentageIO^SQLID\n";
       #print $fh ""
       print $fh @temp;
       close($fh);
}

my $start_time = time();

foreach my $fh(@files){
#       print "Reading file $fh \n";
        open my $FILE, "<$fh" || die "$fh not found";
        @tempStats = &readLines($FILE);
        close($FILE);
        @instanceActivityStats = &removeUnwantedLines(@tempStats);
        &writeToFile(@instanceActivityStats);
		&nullifyArrays(@tempStats);
		&nullifyArrays(@tempInstanceActivityStats);
#      	print "Completed reading file $fh \n";
}

my $end_time = time();
my $run_time = $end_time - $start_time; 
print "Completed task in $run_time seconds \n";
