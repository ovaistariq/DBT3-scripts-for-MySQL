/^\+---.*/{next}
{for (i=1; i<=NF; i++) 
    if (x=match($i,/[\-\+]?[0-9]+\.[0-9]+/))
        $i=sprintf("%.2f",$i);
print}
