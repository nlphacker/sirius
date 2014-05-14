#!/bin/perl

#--- Will need to update the roles array depending on what the latest set of roles are ---#
#---  We will only consider the constituents that were labeled in the end for calculating the recall ---#

$missed = 0;

if ($ARGV[0] eq '-missed') 
{
    shift;
    $missed = shift;
	print STDERR "missed: $missed\n";
} 
else 
{
    $missed = 0;
}

while (<>) 
{
	next unless s/^ //;
	#next if s/\?//;     #--- uncomment this in case we do not want to consider sentences with unseen targets ---#
    chop;
    ($tpos, $true_seq, $single_seq, $seq) = split(/ /);

	#print "-$true_seq\n";
    #print "-$single_seq\n";
	#print "-$seq\n";

    $total_sen++;

    @true_seq = split(/\|/, $true_seq, -1); 
	shift @true_seq; #  
	pop @true_seq;   # shift and pop to avoid getting a null at both ends

    @single_seq = split(/\|/, $single_seq, -1); 
	shift @single_seq;    #
	pop @single_seq;      # shift and pop to avoid getting a null at both ends

    @seq = split(/\|/, $seq, -1); 
	shift @seq;    #
	pop @seq;      # shift and pop to avoid getting a null at both ends

    for $i (0..$#true_seq) 
	{
		$total++; #--- total probable constituents ---#

		$fe = $true_seq[$i] || '*';         #--- this is not required, if the sequence is |*|.. instead of ||.. 
		$best_fe = $single_seq[$i] || '*';  #--- this is not required, if the sequence is |*|.. instead of ||.. 
		 

		$confusion{$fe}{$best_fe}++;
		$rev_confusion{$best_fe}{$fe}++;
        #print "++$tpos $fe $best_fe\n";
		
		#-- sameer: removed the requirement of entering -n option by automatically calculating true_n --#
		if ($fe ne '*')
		{
			$true_n++;
			#print "found a marked fe $true_seq[$i]\n";
		}

		
		#--- this should not ideally happen ---#
		if ($#single_seq <0) 
		{
			$none_out++;
			next;
		}
		
		#--- constituent is not a true fe ---#
		if ($fe eq '*') 
		{
			if ($best_fe eq '*') 
			{
				$correct_false++;         #--- I don't consider this as a correct false ---#
				$type = "correct_false";
			} 
			else 
			{
				$false_pos++;             #-- this is a false positive ---#
				$type = "false_pos";
			}
		} 
		else 
		{
			if ($best_fe eq '*') 
			{
				$false_neg++;             #--- this is false negative ---#
				$type = "false_neg";
			} 
			elsif ($fe eq $best_fe) 
			{
				$correct++;               #--- this is correct positive ---#
				$type = "correct";
			} 
			else 
			{
				$incorrect++;         #--- this is incorrect positive ---#
				$type = "incorrect";
			}
		}
        #print "== $tpos $type $fe $best_fe\n";
	}
}



#----- confusion matrix is -----#
#                fe                                 NOT-fe
# correct positive ($correct + $incorrect )| false positive ($false_pos)           labeled-fe
#------------------------------------------+---------------------------------  
# false negative ($false_neg)              |           -                       NOT-labeled-fe




print "------------------------------------------\n";
print "total actual fe-s           : $true_n\n";
print "correctly labeled fe-s      : $correct\n";
print "incorrectly labeled fe-s    : $incorrect\n";
print "not-labeled fe              : $false_neg\n"; 
print "missed fe                   : $missed\n";


#--- $true_n = $correct + $incorrect + $false_neg ---#

print "incorrectly identified fe-s : $false_pos\n";

if ($true_n + $missed == 0 || $correct + $incorrect + $false_pos == 0 )
{
	if($true_n > 0)
	{
		print "------------------------------------------\n";
		printf "precision                   : 0.00\n";
		printf "recall                      : 0.00\n";
		print "------------------------------------------\n";
	}
	exit;
}

#$recall    = ($correct + $incorrect)/($true_n + $missed);
$recall    = ($correct)/($true_n + $missed);
$precision = ($correct)/($correct + $incorrect + $false_pos);
$unlabeled_recall    = ($correct + $incorrect)/($true_n + $missed);
$unlabeled_precision = ($correct + $incorrect)/($correct + $incorrect + $false_pos);
print "------------------------------------------\n";
printf "precision                   : %0.4f ($correct)/($correct + $incorrect + $false_pos)\n", $precision;
#printf "recall                      : %0.4f ($correct + $incorrect)/($true_n + $missed)\n", $recall;
printf "recall                      : %0.4f ($correct)/($true_n + $missed)\n", $recall;

printf "unlabeled\n";
printf "precision                   : %0.4f ($correct + $incorrect)/($correct + $incorrect + $false_pos)\n", $unlabeled_precision;
printf "unlabeled\n";
printf "recall                      : %0.4f ($correct + $incorrect)/($true_n + $missed)\n", $unlabeled_recall;
print "------------------------------------------\n";

#
#for $true ( sort keys %confusion)
#{
#	print "$true\t";
#	for $best (sort keys %{$confusion{$true}})
#	{
#		print "$best:$confusion{$true}{$best}\t";
#	}
#	print "\n";
#}

undef %recall;
undef %precision;

for $fe_true ( sort keys %confusion )
{
	$denominator = 0;

	$numerator = $confusion{$fe_true}{$fe_true};
	#print "$fe_true: $numerator";
	for $fe_hyp ( sort keys %{$confusion{$fe_true}} )
	{
		$denominator += $confusion{$fe_true}{$fe_hyp};
		#print "  confusion{$fe_true}{$fe_hyp} $confusion{$fe_true}{$fe_hyp}"
	}
	
	if( $denominator != 0 )
	{
		$recall{$fe_true} = $numerator/$denominator;
	}
 
	#print "recall: $fe_true = $recall{$fe_true}\n";
}

for $fe_hyp ( sort keys %rev_confusion )
{
	$denominator = 0;

	$numerator = $rev_confusion{$fe_hyp}{$fe_hyp};
	#print "$fe_hyp: $numerator ";
	for $fe_true ( sort keys %{$rev_confusion{$fe_hyp}} )
	{
		$denominator += $rev_confusion{$fe_hyp}{$fe_true};
		#print "  rev_confusion{$fe_hyp}{$fe_true} $rev_confusion{$fe_hyp}{$fe_true}"
	}
	#print "numerator: $numerator";
	#print "denominator: $denominator ";
	if( $denominator != 0 )
	{
		$precision{$fe_hyp} = $numerator/$denominator;
	}

	#print "precision: $fe_hyp = $precision{$fe_hyp}\n";
}


print "\n\nConfusion matrix:\n";
print "----------------\n\n";
#@roles = ( "*", "agent", "experiencer", "theme", "cause", "result", "instrument", "manner", "means", "location", "temporal", "beneficiary", "goal", "source", "actor", "degree", "equiv", "type", "state", "topic", "proposition", "stimulus", "other");
@roles = ( "ARG0",  "ARG1", "ARG2", "ARG3", "ARG4", "ARG5", "ARGA", "ARGM", "ARG-ADV", "ARGM-CAU", "ARGM-DIR", "ARGM-DIS", "ARGM-EXT", "ARGM-LOC", "ARGM-MNR", "ARGM-MOD", "ARGM-NEG", "ARGM-PNC", "ARGM-PRD", "ARGM-PRP", "ARGM-TMP");

@roles = sort @roles;

#print "\t";
for $something (0..22)
{
	printf "%5s", $something;
}

print "  <-- classified as\n";
print "---------------------------------------------------------------------------------------------------------------------\n";

for $true ( 0..22 )
{
	for $best ( 0..22 )
	{
		if( defined $confusion{$roles[$true]}{$roles[$best]} )
		{
			printf "%5s", $confusion{$roles[$true]}{$roles[$best]};
		}
		else
		{
			printf "%5s", ".";
		}
	}

	printf "  %s: %s (%0.1f/%0.1f)", $true, $roles[$true], $precision{$roles[$true]}*100, $recall{$roles[$true]}*100; 

	print "\n";
}

#print "\n";
#print "Legends:\n";
#print "-------\n\n";
#$jj=0;
#for $role ( @roles )
#{
#	print "$jj: $role\n";
#	$jj++;
#}


#print "NOTE: precision does not take into consideration the incorrectly\n";
#print "identified frame elements\n";


#$correct_p = $correct / $total;
#$correct_false_p = $correct_false / $total;
#$false_pos_p = $false_pos / $total;
#$false_neg_p = $false_neg / $total;
#$incorrect_p = $incorrect_pos / $total;

#exit;
#print "$correct $correct_p correct\n$correct_false $correct_false_p correct_false\n$false_pos $false_pos_p false_pos\n$false_neg $false_neg_p false_neg\n$incorrect_pos $incorrect_pos_p incorrect_p\n";

#$precision = $correct / ($correct + $false_pos + $incorrect);
#$recall = $correct / ($true_n);
#print "precision $precision                 recall $recall\n";

#$precision = (($correct + $incorrect) / ($correct + $false_pos + $incorrect));
#$recall = (($correct + $incorrect) / $true_n);

#print "$total_sen total_sen $total total\n";



