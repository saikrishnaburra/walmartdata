
param ($SettingsFile, 
       $OutputDirectory,
       $NumberDCs,
       $StoreCount,
       $ItemCount,
       $StartDate,
       $Years
	   );
$DCHash=@();
$StartWeekHash=@{};
$EndWeekHash=@{};
function generateDataMain
{
    loadParameters;
    #Remove-Item -path $OutputDirectory -recurse;
    #New-Item $OutputDirectory  -type directory
    generateDCs $NumberDCs;
    generateStores $StoreCount;
    generateItems $ItemCount;
    generateCalendar $StartDate $Years;
    generateStoreStorage $StoreCount;
   # generateItemBod $ItemCount $EffectiveWeek;
    generateDCStorage $NumberDCs;

     Write-Host "Writing DCLabour...";    
  $FileNamePrefix = 'Fact.DCLabour'
  $sliceId = 0;
  $Weeks=$Weeks/$Slices;
  $StartWeek=0;
  $EndWeek=[math]::floor($Weeks);
  $Jobs = @();
  write-host "weeks are "+$Weeks;
  1..$Slices | ForEach-Object { $sliceId = 0; } {
    $jobName = "FactDCLabour-Slice-$($sliceId)";
    $job = Start-Job -Name $jobName -ScriptBlock $generateDCLabourFacts -ArgumentList $OutputDirectory, $FileNamePrefix, $NumberDCs,$Weeks,$StartWeek,$EndWeek,$sliceId;
    $sliceId++;
    $EndWeek+=[math]::floor($Weeks);
    $StartWeek+=[math]::floor($Weeks);
    $Jobs += $job.ID;
  }
  
  Wait-Job -Id $Jobs;
  Write-Host "Writing StoreLabour...";
  $FileNamePrefix = 'Fact.StoreLabour'
  $StartWeek=0;
  $EndWeek=[math]::floor($Weeks);
  $Jobs = @();
   1..$Slices | ForEach-Object { $sliceId = 0; } {
    $jobName = "FactStoreLabour-Slice-$($sliceId)";
    $job = Start-Job -Name $jobName -ScriptBlock $generateStoreLabourFacts -ArgumentList $OutputDirectory, $FileNamePrefix, $StoreCount,$Weeks,$StartWeek,$EndWeek,$sliceId;
    $sliceId++;
    $EndWeek+=[math]::floor($Weeks);
    $StartWeek+=[math]::floor($Weeks);
    $Jobs += $job.ID;
  }

  Wait-Job -Id $Jobs;
  Write-Host "Writing CarrierCapacity...";
  $FileNamePrefix = 'Fact.Carrier Capacity'
  $StartWeek=0;
  $EndWeek=[math]::floor($Weeks);
  $Jobs = @();
   1..$Slices | ForEach-Object { $sliceId = 0; } {
    $jobName = "FactCarrierCapacity-Slice-$($sliceId)";
    $job = Start-Job -Name $jobName -ScriptBlock $generateCarrierCapacityFacts -ArgumentList $OutputDirectory, $FileNamePrefix, $StoreCount,$Weeks,$StartWeek,$EndWeek,$sliceId,$NumberDCs;
    $sliceId++;
    $EndWeek+=[math]::floor($Weeks);
    $StartWeek+=[math]::floor($Weeks);
    $Jobs += $job.ID;
  }
  Wait-Job -Id $Jobs;
 Write-Host "Writing EveryDay ForeCastedDemand...";
  $FileNamePrefix = 'Fact.EveryDayDemand'
  $StartWeek=0;
  $EndWeek=[math]::floor($Weeks);
  $Jobs = @();
   1..$Slices | ForEach-Object { $sliceId = 0; } {
    $jobName = "FactCarrierCapacity-Slice-$($sliceId)";
    $job = Start-Job -Name $jobName -ScriptBlock $generateEveryDayForecastedDemandFacts -ArgumentList $OutputDirectory, $FileNamePrefix, $StoreCount,$Weeks,$StartWeek,$EndWeek,$sliceId,$NumberDCs,$ItemCount;
    $sliceId++;
    $EndWeek+=[math]::floor($Weeks);
    $StartWeek+=[math]::floor($Weeks);
    $Jobs += $job.ID;
  }
  Wait-Job -Id $Jobs;
 Write-Host "Writing On Hand Inventory...";
  $FileNamePrefix = 'Fact.OnHandInventory'
  $StartWeek=0;
  $EndWeek=[math]::floor($Weeks);
  $Jobs = @();
   1..$Slices | ForEach-Object { $sliceId = 0; } {
    $jobName = "FactCarrierCapacity-Slice-$($sliceId)";
    $job = Start-Job -Name $jobName -ScriptBlock $generateOnHandInventoryFacts -ArgumentList $OutputDirectory, $FileNamePrefix, $StoreCount,$Weeks,$StartWeek,$EndWeek,$sliceId,$NumberDCs,$ItemCount;
    $sliceId++;
    $EndWeek+=[math]::floor($Weeks);
    $StartWeek+=[math]::floor($Weeks);
    $Jobs += $job.ID;
  }
  Wait-Job -Id $Jobs;
  Write-Host "Writing In Transit...";
  $FileNamePrefix = 'Fact.InTransit'
  $StartItem=0;
  $ItemSliceCount=[math]::floor($ItemCount/$Slices);
  $EndItem=[math]::floor($ItemSliceCount);
  $Jobs = @();
   1..$Slices | ForEach-Object { $sliceId = 0; } {
    $jobName = "FactCarrierCapacity-Slice-$($sliceId)";
    $job = Start-Job -Name $jobName -ScriptBlock $generateInTransitFacts -ArgumentList $OutputDirectory, $FileNamePrefix, $StoreCount,$Weeks,$StartItem,$EndItem,$sliceId,$NumberDCs,$ItemCount;
    $sliceId++;
    $EndItem+=[math]::floor($ItemSliceCount);
    $StartItem+=[math]::floor($ItemSliceCount);
    $Jobs += $job.ID;
  }
  Wait-Job -Id $Jobs;
  Write-Host "Writing Open Purchase Orders...";
  $FileNamePrefix = 'Fact.OpenPurchaseOrders'
  $StartDC=0;
  $EndDC=[math]::floor($NumberDCs/$Slices);
  $Jobs = @();
   1..$Slices | ForEach-Object { $sliceId = 0; } {
    $jobName = "FactCarrierCapacity-Slice-$($sliceId)";
    $job = Start-Job -Name $jobName -ScriptBlock $generatePurchaseOrderFacts -ArgumentList $OutputDirectory, $FileNamePrefix, $StoreCount,$Weeks,$StartDC,$EndDC,$sliceId,$NumberDCs,$ItemCount;
    $sliceId++;
    $EndDC+=[math]::floor($NumberDCs/$Slices);
    $StartDC+=[math]::floor($NumberDCs/$Slices);
    $Jobs += $job.ID;
  }
  Wait-Job -Id $Jobs;
  Write-Host "Writing DCWork Orders...";
  $FileNamePrefix = 'Fact.DCWorkOrders'
  $StartDC=0;
  $EndDC=[math]::floor($NumberDCs/$Slices);
  $Jobs = @();
   1..$Slices | ForEach-Object { $sliceId = 0; } {
    $jobName = "FactCarrierCapacity-Slice-$($sliceId)";
    $job = Start-Job -Name $jobName -ScriptBlock $generateDCWorkOrderFacts -ArgumentList $OutputDirectory, $FileNamePrefix, $StoreCount,$Weeks,$StartDC,$EndDC,$sliceId,$NumberDCs,$ItemCount;
    $sliceId++;
    $EndDC+=[math]::floor($NumberDCs/$Slices);
    $StartDC+=[math]::floor($NumberDCs/$Slices);
    $Jobs += $job.ID;
  }
  Wait-Job -Id $Jobs;
   Write-Host "Writing InventoryPolicy...";
  $FileNamePrefix = 'Fact.InventoryPolicy'
  $StartWeek=0;
  $EndWeek=[math]::floor($Weeks);
  $Jobs = @();
   1..$Slices | ForEach-Object { $sliceId = 0; } {
    $jobName = "FactCarrierCapacity-Slice-$($sliceId)";
    $job = Start-Job -Name $jobName -ScriptBlock $generateInvPolicy -ArgumentList $OutputDirectory, $FileNamePrefix, $StoreCount,$Weeks,$StartWeek,$EndWeek,$sliceId,$NumberDCs,$ItemCount;
    $sliceId++;
    $EndDC+=[math]::floor($NumberDCs/$Slices);
    $StartDC+=[math]::floor($NumberDCs/$Slices);
    $Jobs += $job.ID;
  }
  Wait-Job -Id $Jobs;
  Write-Host "Writing ItemBodNetworkFlow...";
 # write-host $EffectiveWeek;
  $FileNamePrefix = 'Fact.ItemBodNetwork'
  $StartItem=0;
  $EndItem=[math]::floor($ItemCount/$Slices);
  $Jobs = @();
   1..$Slices | ForEach-Object { $sliceId = 0; } {
    $jobName = "FactCarrierCapacity-Slice-$($sliceId)";
    $job = Start-Job -Name $jobName -ScriptBlock $generateItemBod -ArgumentList $OutputDirectory, $FileNamePrefix, $StoreCount,$Weeks,$StartItem,$EndItem,$sliceId,$NumberDCs,$ItemCount,$StartWeekHash,$EndWeekHash;
    $sliceId++;
   # $EndItem+=[math]::floor($ItemCount/$Slices);
   # $StartItem+=[math]::floor($ItemCount/$Slices);
    $Jobs += $job.ID;
  }
  Wait-Job -Id $Jobs; 
   
}
$generateInvPolicy={
	param($OutputDirectory,$FileNamePrefix,$StoreCount,$Weeks,$StartWeek,$EndWeek,$sliceId,$NumberDCs,$ItemCount);
    $InvFile=[System.IO.StreamWriter] ("$OutputDirectory\$FileNamePrefix-$($sliceId).csv");
	$DemandType=@("Base","Promotional");
	$InvFile.writeline("WeekNo,LocationNo,ItemNo,SafetyStock,Min,Max,Presentation Min");
	
	for($WeekInd=$StartWeek;$WeekInd -lt $EndWeek;$WeekInd++)
	{
	for($ItemInd=0;$ItemInd -lt $ItemCount;$ItemInd++){
	for($StoreLocInd=500000;$StoreLocInd -lt (500000+$StoreCount);$StoreLocInd++)
	{
	
      $SafStock=get-random -minimum 100 -maximum 200;
      $Mindays=get-random -minimum 1 -maximum 10;
      $MaxDays=get-random -minimum $Mindays -maximum 20;
      $PMin=get-random -minimum 100 -maximum 200;
      $InvFile.writeline($WeekInd.ToString()+","+$StoreLocInd+","+$ItemInd+","+$SafStock+","+$Mindays+","+$MaxDays+","+$PMin);
 
	}
	for($DCInd=0;$DCInd -lt $NumberDCs;$DCInd++)
	{
      $SafStock=get-random -minimum 100 -maximum 200;
      $Mindays=get-random -minimum 1 -maximum 10;
      $MaxDays=get-random -minimum $Mindays -maximum 20;
      $PMin=get-random -minimum 100 -maximum 200;
      $InvFile.writeline($WeekInd.ToString()+","+$StoreLocInd+","+$ItemInd+","+$SafStock+","+$Mindays+","+$MaxDays+","+$PMin);
	}
	}
	}
    $InvFile.close();

}
$generateDCWorkOrderFacts=
{
	param($OutputDirectory,$FileNamePrefix,$StoreCount,$Weeks,$StartDC,$EndDC,$sliceId,$NumberDCs,$ItemCount);
    $WOFile=[System.IO.StreamWriter] ("$OutputDirectory\$FileNamePrefix-$($sliceId).csv");
	$WOFile.writeline("ShipDate,ReceiptDate,FromLocationNo,ToLocationNo,WorkOrderNo,ItemNo,WorkOrderUnits");
	$WorkOrdNo=0;
	for($DCInd=$StartDC;$DCInd -lt $EndDC;$DCInd++)
	{
	for($ItemInd=0;$ItemInd -lt $ItemCount;$ItemInd++)
	{
    for($DInd=0;$DInd -lt $NumberDCs;$DInd++)
    {
    [DateTime]$theMin = "1/1/2017";
    [DateTime]$theMax = [DateTime]::Now;
    $theRandomGen = new-object random;
    $theRandomTicks = [Convert]::ToInt64( ($theMax.ticks * 1.0 - $theMin.Ticks * 1.0 ) * $theRandomGen.NextDouble() + $theMin.Ticks * 1.0 );
    $Date=new-object DateTime($theRandomTicks);
    $ShipDate=Get-Date $Date -Format 'yyyy-MM-dd';

    $rand=get-random -minimum 1 -maximum 7;
    $Date.AddDays($rand);
    $RDate=Get-Date $Date -Format 'yyyy-MM-dd'
    $WOUnits=get-random -minimum  1000 -maximum 20000;
    $WOFile.writeline($ShipDate+","+$RDate+","+$DCInd+","+$DInd+","+$WorkOrdNo+","+$ItemInd+","+$WOUnits);
    $WorkOrdNo++;
	}
    
    for($StoreInd=500000;$StoreInd -lt (500000+$StoreCount);$StoreInd++){
    [DateTime]$theMin = "1/1/2017";
    [DateTime]$theMax = [DateTime]::Now;
    $theRandomGen = new-object random;
    $theRandomTicks = [Convert]::ToInt64( ($theMax.ticks * 1.0 - $theMin.Ticks * 1.0 ) * $theRandomGen.NextDouble() + $theMin.Ticks * 1.0 );
    $Date=new-object DateTime($theRandomTicks);
    $ShipDate=Get-Date $Date -Format 'yyyy-MM-dd';

    $rand=get-random -minimum 1 -maximum 7;
    $Date.AddDays($rand);
    $RDate=Get-Date $Date -Format 'yyyy-MM-dd'
    $WOUnits=get-random -minimum  1000 -maximum 20000;
    $WOFile.writeline($ShipDate+","+$RDate+","+$DCInd+","+$StoreInd+","+$WorkOrdNo+","+$ItemInd+","+$WOUnits);
    $WorkOrdNo++;
	}
	}
	}
    $WOFile.close();
}
$generatePurchaseOrderFacts={
	param($OutputDirectory,$FileNamePrefix,$StoreCount,$Weeks,$StartDC,$EndDC,$sliceId,$NumberDCs,$ItemCount);
    $POFile=[System.IO.StreamWriter] ("$OutputDirectory\$FileNamePrefix-$($sliceId).csv");
	$POFile.writeline("PO.No,POType,OrderDate,ShipDate,ReceiptDate,VendorNo,VendorName,DCNo,ItemNo,AcctDept,OrderDept,POUnits");
	
	for($DCInd=$StartDC;$DCInd -lt $EndDC;$DCInd++)
	{
	for($ItemInd=0;$ItemInd -lt $ItemCount;$ItemInd++)
	{
    $PONo=get-random -minimum 3000000000 -maximum 5000000000;
    $PoType=get-random -minimum 10 -maximum 100;
    [DateTime]$theMin = "1/1/2017";
    [DateTime]$theMax = [DateTime]::Now;
    $theRandomGen = new-object random;
    $theRandomTicks = [Convert]::ToInt64( ($theMax.ticks * 1.0 - $theMin.Ticks * 1.0 ) * $theRandomGen.NextDouble() + $theMin.Ticks * 1.0 );
    $Date=new-object DateTime($theRandomTicks);
    $orderDate=Get-Date $Date -Format 'yyyy-MM-dd';

    $rand=get-random -minimum 1 -maximum 7;
    $Date.AddDays($rand);
    $ShipDate=Get-Date $Date -Format 'yyyy-MM-dd'
    $RDate=$ShipDate; 
    $VendorNo=get-random -minimum 1000000 -maximum 2000000;
    $VendorName="Vendor-"+$VendorNo;
    $AccDept=get-random -minimum 1 -maximum 100;
    $OrdDept=get-random -minimum 1 -maximum 100;
    $DOUnits=get-random -minimum  100 -maximum 200;
    $POFile.writeline($PONo.ToString()+","+$PoType+","+$orderDate+","+$ShipDate+","+$RDate+","+$VendorNo+","+$VendorName+","+$DCInd+","+$ItemInd+","+$AccDept+","+$OrdDept+","+$DOUnits);
	
	}
	}
    $POFile.close();
}
$generateInTransitFacts={
		param($OutputDirectory,$FileNamePrefix,$StoreCount,$Weeks,$StartItem,$EndItem,$sliceId,$NumberDCs,$ItemCount);
     $TFile=[System.IO.StreamWriter] ("$OutputDirectory\$FileNamePrefix-$($sliceId).csv");
	$TFile.writeline("ReceiptDate,ItemNo,FromLocationNo,FromLocationType,ToLocationNo,ToLocationType,InTransitUnits");
	
	for($ItemInd=$StartItem;$ItemInd -lt $EndItem;$ItemInd++)
	{
	for($DCInd=0;$DCInd -lt $NumberDCs;$DCInd++)
	{
	for($StoreInd=500000;$StoreInd -lt (500000+$StoreCount);$StoreInd++){
      [DateTime]$theMin = "1/1/2017";
    [DateTime]$theMax = [DateTime]::Now;
    $theRandomGen = new-object random;
    $theRandomTicks = [Convert]::ToInt64( ($theMax.ticks * 1.0 - $theMin.Ticks * 1.0 ) * $theRandomGen.NextDouble() + $theMin.Ticks * 1.0 );
    $Date=new-object DateTime($theRandomTicks);
    $RDate=Get-Date $Date -Format 'yyyy-MM-dd';
      $InvVolume=get-random -minimum 100 -maximum 200;
      $TFile.writeline($RDate+","+$ItemInd+","+$DCInd+","+"DC,"+$StoreInd+","+"Store,"+$InvVolume);
	  
	}
	}
	}
    $TFile.close();
}
$generateOnHandInventoryFacts={
	param($OutputDirectory,$FileNamePrefix,$StoreCount,$Weeks,$StartWeek,$EndWeek,$sliceId,$NumberDCs,$ItemCount);
   $InvFile=[System.IO.StreamWriter] ("$OutputDirectory\$FileNamePrefix-$($sliceId).csv");
	$InvFile.writeline("Week No,Location No,Item No,Inventory Units");
	
	for($WeekInd=$StartWeek;$WeekInd -lt $EndWeek;$WeekInd++)
	{
	for($DCInd=0;$DCInd -lt $NumberDCs;$DCInd++)
	{
	for($ItemInd=0;$ItemInd -lt $ItemCount;$ItemInd++){

      $InventoryUnits=get-random -minimum 10 -maximum 100;
      $InvFile.writeline($WeekInd.ToString()+","+$DCInd+","+$ItemInd+","+$InventoryUnits);
	
	}
	}
	}
    $InvFile.close();
}
$generateEveryDayForecastedDemandFacts={
	param($OutputDirectory,$FileNamePrefix,$StoreCount,$Weeks,$StartWeek,$EndWeek,$sliceId,$NumberDCs,$ItemCount);
	$EveryDayDemand=[System.IO.StreamWriter] ("$OutputDirectory\$FileNamePrefix-$($sliceId).csv");
	$DemandType=@("Base","Promotional");
	$EveryDayDemand.writeline("Week No,Store No,Item No,Demand Type,Forecast");
	
	for($WeekInd=$StartWeek;$WeekInd -lt $EndWeek;$WeekInd++)
	{
	for($StoreLocInd=500000;$StoreLocInd -lt (500000+$StoreCount);$StoreLocInd++)
	{
	for($ItemInd=0;$ItemInd -lt $ItemCount;$ItemInd++){
      $DType=get-random $DemandType -count 1;
      $ForeCast=get-random -minimum 100 -maximum 200;
      $EveryDayDemand.writeline($WeekInd.ToString()+","+$StoreLocInd+","+$ItemInd+","+$DType+","+$ForeCast);
      
	}
	}
	}
    $EveryDayDemand.close();
}
$generateCarrierCapacityFacts={
	param($OutputDirectory,$FileNamePrefix,$StoreCount,$Weeks,$StartWeek,$EndWeek,$sliceId,$NumberDCs);
	$CCPFile=[System.IO.StreamWriter] ("$OutputDirectory\$FileNamePrefix-$($sliceId).csv")
	$RType=@("Refigerated","NonRefigerated");
	$CCPFile.writeline("Week No,Carrier No,Resource Type,Trailers#,FlexTrailers#,FromLocationNo,ToLocationNo");
	$CNo=0;
	for($WeekInd=$StartWeek;$WeekInd -lt $EndWeek;$WeekInd++)
	{
	for($DCLocInd=0;$DCLocInd -lt $NumberDCs;$DCLocInd++)
	{
	for($StoreLocInd=500000;$StoreLocInd -lt (500000+$StoreCount);$StoreLocInd++)
	{
	  $ResType=get-random $RType -count 1;
	  $BaseT=get-random -minimum 100 -maximum 200;
	  $FlexT=get-random -minimum 100 -maximum $BaseT;
      $CCPFile.writeline($WeekInd.ToString()+","+$CNo+","+$ResType+","+$BaseT+","+$FlexT+","+$DCLocInd+","+$StoreLocInd);
      $CNo++;
	}
	}
	}
    $CCPFile.close();
}
$generateStoreLabourFacts=
{
  param($OutputDirectory, $FileNamePrefix, $StoreCount,$Weeks,$StartWeek,$EndWeek,$sliceId);
  $Shift=@("A1","A2","B1","B2");
	$resourceType=@("Handling","Shipping","Recieving");
  $StoreLabourFile=[System.IO.StreamWriter] ("$OutputDirectory\$FileNamePrefix-$($sliceId).csv")
  $StoreLabourFile.writeline("Week No,Shift,Store No,Resource Type,Hours Per Week Base,Hours per Week Flex");
	for($WeekInd=$StartWeek;$WeekInd -lt $EndWeek;$WeekInd++)
	{
	   for($StoreInd=0;$StoreInd -lt $StoreCount;$StoreInd++)
	   {  
	      $StoreKey=$StoreInd+500000;
	      $shift=get-random $shift -count 1;
	      $res=get-random $resourceType -count 1;
	      $BaseHrs=get-random -minimum 40 -maximum 50;
	      $FlexHrs=get-random -minimum 10 -maximum 20;
          $StoreLabourFile.writeline($WeekInd.ToString()+","+$shift+","+$StoreKey+","+$res+","+$BaseHrs+","+$FlexHrs);
	   }
	}
	$StoreLabourFile.close();
}
$generateDCLabourFacts = {
	param($OutputDirectory, $FileNamePrefix,$NumberDCs,$Weeks,$StartWeek,$EndWeek,$sliceId);
	$Shift=@("A1","A2","B1","B2");
	$resourceType=@("Handling","Shipping","Recieving");
  $DCLabourFile=[System.IO.StreamWriter] ("$OutputDirectory\$FileNamePrefix-$($sliceId).csv")
  $DCLabourFile.writeline("Week No,Shift,DC No,Resource Type,Hours Per Week Base,Hours per Week Flex");

	for($WeekInd=$StartWeek;$WeekInd -lt $EndWeek;$WeekInd++)
	{
	   for($DCInd=0;$DCInd -lt $NumberDCs;$DCInd++)
	   {  
          
	      $shift=get-random $shift -count 1;
	      $res=get-random $resourceType -count 1;
	      $BaseHrs=get-random -minimum 40 -maximum 50;
	      $FlexHrs=get-random -minimum 10 -maximum 20;
          $DCLabourFile.writeline($WeekInd.ToString()+","+$shift+","+$DCInd+","+$res+","+$BaseHrs+","+$FlexHrs);
	   }
	}
	$DCLabourFile.close();
}
function generateDCStorage 
{
	param($NumberDCs);
   $DCStorageFile= [System.IO.StreamWriter] ("$OutputDirectory\DC Storage.csv");
   $DCStorageFile.writeline("DCNo,Storage Type,Cubic Feet-Prime,Cubic Feet Reserve,Flex Storage");
   for($DCStoreInd=0;$DCStoreInd -lt $NumberDCs;$DCStoreInd++)
   {
     $CubicFeetPrime=get-random -minimum 1001 -maximum 2000;
     $CubicFeetReserve=get-random -minimum 1000 -maximum $CubicFeetPrime;
     $FlexStorage=$CubicFeetReserve;
     $DCStorageFile.writeline($DCStoreInd.ToString()+","+"StorageType-"+$DCStoreInd+","+$CubicFeetPrime+","+$CubicFeetReserve+","+$FlexStorage);
   }
   $DCStorageFile.close();
}
function generateDCs
{
 param($NumberDCs);
 $DCTypes=@("Import","Fashion","Regional","Grocery");
 $DCStatuses=@("Active","Inactive");
 $DCFile = [System.IO.StreamWriter] ("$OutputDirectory\DC Master.csv");
 $DCFile.writeline("DC No, DC Type, DC Region,DCKey,DC Name,DC City, DC State,DCSqFt,DC ZipCode,DC Status,OpenDate,CloseDate");
 for($DCInd=0;$DCInd -lt $NumberDCs;$DCInd=$DCInd+1)
{
   
    $DCTypeRand=get-random $DCTypes -count 1;
    $DCRegion="Region-"+$DCInd;
    $DCName="DC-"+$DCInd;
    $DCCity="City-"+[math]::floor($DCInd/10);
    $DCState="State-"+[math]::floor($DCInd/20);
    $DCSqFt=get-random -minimum 1000000 -maximum 2000000;
    $DCZip=get-random -minimum 100000 -maximum 999999;
    $DCStatus=get-random $DCStatuses -count 1;
    [DateTime]$theMin = "1/1/2008";
    [DateTime]$theMax = [DateTime]::Now;
    $theRandomGen = new-object random;
    $theRandomTicks = [Convert]::ToInt64( ($theMax.ticks * 1.0 - $theMin.Ticks * 1.0 ) * $theRandomGen.NextDouble() + $theMin.Ticks * 1.0 );
    $Date=new-object DateTime($theRandomTicks);
    $OpenDate=Get-Date $Date -Format 'yyyy-MM-dd';
    $theMin=$Date;
    $theRandomGen = new-object random
    $theRandomTicks = [Convert]::ToInt64( ($theMax.ticks * 1.0 - $theMin.Ticks * 1.0 ) * $theRandomGen.NextDouble() + $theMin.Ticks * 1.0 );
    $Date=new-object DateTime($theRandomTicks);
    $CloseDate=Get-Date $Date -Format 'yyyy-MM-dd';
	$DCFile.writeline($DCInd.ToString()+","+$DCTypeRand+","+$DCRegion+","+$DCInd+","+$DCName+","+$DCCity+","+$DCState+","+$DCSqFt+","+$DCZip+","+$DCStatus+","+$OpenDate+","+$CloseDate);
}
$DCFile.close();
}
function generateStoreStorage
{
	param($StoreCount);
	$StFile = [System.IO.StreamWriter] ("$OutputDirectory\Store Storage.csv");
	$StFile.writeline("StoreNo,StorageType,CubicFeet,FlexStorage");
	for($StoreInd=0;$StoreInd -lt $StoreCount;$StoreInd=$StoreInd+1)
	{
	   $StoreKey=$StoreInd+500000;
	   $CubicFeet=get-random -minimum 1000 -maximum 2000;
	   $StFile.writeline($StoreKey.ToString()+","+"Type-"+[math]::floor($StoreInd/10)+","+$CubicFeet+","+"Storage-"+$StoreInd);
	}
	$StFile.close();
}
 $generateItemBod =
{
	param($OutputDirectory, $FileNamePrefix,$StoreCount,$Weeks,$StartItem,$EndItem,$sliceId,$NumberDCs,$ItemCount,$StartWeekHash,$EndWeekHash);    
	$Transport=@("Road","Railways","Flight","Ships");
	write-host $EffectiveWeek;	
	$ItemBodFile=[System.IO.StreamWriter] ("$OutputDirectory\$FileNamePrefix-$($sliceId).csv");
	$ItemBodFile.writeline("Effective Start Week,Effective End Week,ItemNo,From Location No,To Location No,Load Time,Transport Mode,Priority");
	for($ItemBodInd=$StartItem;$ItemBodInd -lt $EndItem;$ItemBodInd++)
    {  
      for($DCInd=0;$DCInd -lt $NumberDCs;$DCInd++){
      for($DCid=0;$DCid -lt $NumberDCs;$DCid++)
      {
      $stweek=$EffectiveWeek[$ItemBodInd,0];
      $endweek=$EffectiveWeek[$ItemBodInd,1];
      $EffStartWeek=get-date $stweek;
      $EffEndWeek=get-date $endweek; 
      #write-host $EffStartWeek;
      #write-host $EffEndWeek;
      $EffStartWeek=$EffStartWeek.AddDays(6);
      $EffEndWeek=$EffEndWeek.AddDays(6);
      $EffStartWeek=get-date $EffStartWeek -format "yyyy-MM-dd";
      $EffEndWeek=get-date $EffEndWeek -format "yyyy-MM-dd";
      $ItemNo=$ItemBodInd;
      $FromLocNo=$DCInd;
      $ToLocNo=$DCid;
      $LoadTime=get-random -minimum 1 -maximum 10;
      $TransportMode=get-random $Transport -count 1;
      $Priority=get-random -minimum 1 -maximum 10;
      $ItemBodFile.writeline($EffStartWeek.ToString()+","+$EffEndWeek+","+$ItemNo+","+$FromLocNo+","+$ToLocNo+","+$LoadTime+","+$TransportMode+","+$Priority);
      #$ItemBodFile.writeline($EffStartWeek.ToString()+","+$EffEndWeek+","+$ItemNo+","+$FromLocNo+","+$ToLocNo+","+$LoadTime+","+$TransportMode+","+$Priority);
      }
      for($StoreInd=500000;$StoreInd -lt (500000+$StoreCount);$StoreInd++){
      $stweek=$StartWeekHash.Get_Item($ItemBodInd);
      $endweek=$EndWeekHash.Get_Item($ItemBodInd);
      #$stweek=$EffectiveWeek[$ItemBodInd,0];
      #$endweek=$EffectiveWeek[$ItemBodInd,1];
      $EffStartWeek=get-date $stweek;
      $EffEndWeek=get-date $endweek;
      #write-host $EffStartWeek;
      #write-host $EffEndWeek;
      $EffStartWeek=$EffStartWeek.AddDays(6);
      $EffEndWeek=$EffEndWeek.AddDays(6);
      $EffStartWeek=get-date $EffStartWeek -format "yyyy-MM-dd";
      $EffEndWeek=get-date $EffEndWeek -format "yyyy-MM-dd";
      $ItemNo=$ItemBodInd;
      $FromLocNo=$DCInd;
      $ToLocNo=$StoreInd;
      $LoadTime=get-random -minimum 1 -maximum 10;
      $TransportMode=get-random $Transport -count 1;
      $Priority=get-random -minimum 1 -maximum 10;
      $ItemBodFile.writeline($EffStartWeek.ToString()+","+$EffEndWeek+","+$ItemNo+","+$FromLocNo+","+$ToLocNo+","+$LoadTime+","+$TransportMode+","+$Priority);
     }

     }
    }
    $ItemBodFile.close();
}
function generateStores
{
	param($StoreCount);
	$StrState=@("Active","In-active");
	$StoreFile = [System.IO.StreamWriter] ("$OutputDirectory\Store Master.csv");
	$StoreFile.writeline("Store No,Market No,Market Name,Region No,Region Name,Sub-divison No,Sub-division Name,Division No,Divison Name,BU No,BU Name,MarketMgr,MrktHomeStr,StrMgr,StreetAddr,StrCity,StrState,StrZipCode,StrSqFt,StrType,StrStatus,OpenDate,CloseDate,Longitude,Latitude");
	for($StoreInd=0;$StoreInd -lt $StoreCount;$StoreInd=$StoreInd+1)
	{
	     $StoreNo=$StoreInd;
	     $MarketNo=$StoreInd;
	     $MarketName="Market-"+[math]::floor($MarketNo/5);
	     $RegionNo=$StoreInd;
	     $RegionName="Region-"+[math]::floor($RegionNo/10);
	     $SubDivNo=[math]::floor($StoreInd/15);
	     $SubDivName="SubDiv-"+$SubDivNo;
	     $DivNo=[math]::floor($StoreInd/20);
	     $DivName="Division-"+$DivNo;
	     $BuNo=$StoreInd;
	     $BuName="Bu-"+$StoreInd;
	     $MarketMgr="mgr-"+[math]::floor($StoreInd/10);
	     $MrktHomeStr=get-random -minimum 1000 -maximum 9999;
	     $StrMgr="Mgr-"+$StoreInd;
	     $StreetAddr="Addr-"+$StoreInd;
	     $StrCity="City-"+[math]::floor($StoreInd/10);
         $StrState="State-"+[math]::floor($StoreInd/20);
         $StrZipCode=get-random -minimum 100000 -maximum 999999;
         $StrSqFt=get-random -minimum 1000000 -maximum 9999999;
         $StrType="StrType-"+$StoreInd;
         $StrStatus=get-random $StrState -count 1;
          [DateTime]$theMin = "1/1/2008";
    [DateTime]$theMax = [DateTime]::Now;
    $theRandomGen = new-object random;
    $theRandomTicks = [Convert]::ToInt64( ($theMax.ticks * 1.0 - $theMin.Ticks * 1.0 ) * $theRandomGen.NextDouble() + $theMin.Ticks * 1.0 );
    $Date=new-object DateTime($theRandomTicks);
    $OpenDate=Get-Date $Date -Format 'yyyy-MM-dd';
    $theMin=$Date;
    $theRandomGen = new-object random
    $theRandomTicks = [Convert]::ToInt64( ($theMax.ticks * 1.0 - $theMin.Ticks * 1.0 ) * $theRandomGen.NextDouble() + $theMin.Ticks * 1.0 );
    $Date=new-object DateTime($theRandomTicks);
    $CloseDate=Get-Date $Date -Format 'yyyy-MM-dd';
         $Latitude=get-random -minimum 0.0  -Maximum 90.0;
         $Longitude=get-random -minimum 0.0 -maximum 180.0;
         $StoreFile.writeline($StoreNo.ToString()+","+$MarketNo+","+$MarketName+","+$RegionNo+","+$RegionName+","+$SubDivNo+","+$SubDivName+","+$DivNo+","+$DivName+","+$BuNo+","+$BuName+","+$MarketMgr+","+$MrktHomeStr+","+$StrMgr+","+$StreetAddr+","+$StrCity+","+$StrState+","+$StrZipCode+","+$StrSqFt+","+$StrType+","+$StrStatus+","+$OpenDate+","+$CloseDate+","+$Longitude+","+$Latitude);
	}
	$StoreFile.close();
}
function generateItems{
	param($ItemCount);
	$Network=@("Regional","Grocery","DSDC");
	$Flowpolicy=@("x-dock","staple","assembly");
	$BoolString=@("Y","N");
	$Status=@("Active","In-active");
	$Flag=@("Import","Domestic");
	$Type=@("Everyday","Seasonal");
	$ItemFile = [System.IO.StreamWriter] ("$OutputDirectory\Item Master.csv");
	$ItemFile.writeline("Operating Company,Merch Zone No,Merch Zone Name,Dept No,Dept Name,Category Group No,Category Group Name,Category No,Category Name,Sub Category No,Sub Category Name,Fileline No,Fineline Name,CID,Style No,Style Desc,Style Color No,Style Color Desc,Item No,Item Name,Vendor Name,Vendor No,9 digit Vendor No,Network,Flow Policy at IDC,Flow Policy at RDC,Breakpack,Item Conveyable,Base Unit Retail,Unit Cost,Item Weight,Item Length,Item Height,Item Width,VNPK Length,VNPK Width,VNPK Height,VNPK Weight,VNPK Cost,VNPK Quantity,WHPK Length,WHPK Width,WHPK Height,WHPK Weight,WHPK Unit Cost,WHPK Quantity,Effective Start Date,Effective End Date,Item Status,Source Flag,Product Type");
	 $script:EffectiveWeek= New-Object 'object[,]' $ItemCount,2;
	for($ItemInd=0;$ItemInd -lt $ItemCount;$ItemInd=$ItemInd+1)
	{
	  $OptCompany="OptCompany-"+$ItemInd;
      $MerchZoneNo=$ItemInd;
      $MerchZoneName="MerchZone-"+$ItemInd;
      $DeptNo=$ItemInd;
      $DeptName="Dept-"+$ItemInd;
      $CatGroupNo=[math]::floor($ItemInd/20);
      $CatGroupName="CatGroup-"+$CatGroupNo;
      $CatNo=[math]::floor($ItemInd/10);
      $CatName="Cat-"+$CatNo;
      $SubCatNo=[math]::floor($ItemInd/5);
      $SubCatName="SubCat-"+$SubCatNo;
      $FineLineNo=$ItemInd;
      $FineLineName="FineLine-"+$ItemInd;
      $CID=$ItemInd;
      $StyleNo=$ItemInd;
      $StyleDesc="Style-"+$ItemInd;
      $StyleColorNo=$ItemInd;
      $StyleColorDesc="ColorDesc-"+$ItemInd;
      $ItemNo=$ItemInd;
      $ItemName="Item-"+$ItemInd;
      $VendorName="Vendor-"+$ItemInd;
      $VendorNo=100000+$ItemInd;
      $VendorNo9=100000000+$ItemInd;
      $Network=get-random $Network -count 1;
      $FlowPolIDC=get-random $FlowPolicy -count 1;
      $FlowPolRDC=get-random $FlowPolicy -count 1;
      $BreakPack=get-random $BoolString -count 1;
      $ItemConv=get-random $BoolString -count 1;
      $BaseUnitRetail=get-random -minimum 10.0 -maximum 20.0;
      $UnitCost=get-random -minimum 5.0 -maximum 20.0;
      $ItemWeight=get-random -minimum 1.0 -maximum 10.0;
      $ItemLength=get-random -minimum 1.0 -maximum 10.0;
      $ItemHeight=get-random -minimum 1 -maximum 20;
      $ItemWidth=get-random -minimum 1.0 -maximum 10.0;
      $VNPKLength=get-random -minimum 1 -maximum 30;
      $VNPKWidth=get-random -minimum 1.0 -maximum 30.0;
      $VNPKHeight=get-random -minimum 1.0 -maximum 30.0;
      $VNPKWeight=get-random -minimum 1 -maximum 50;
      $VNPKCost=get-random -minimum 1 -maximum 30;
      $VNPKQuantity=get-random -minimum 1.0 -maximum 50.0;
      $WHPKLength=get-random -minimum 1.0 -maximum 30.0;
      $WHPKWidth=get-random -minimum 10.0 -maximum 30.0;
      $WHPKHeight=get-random -minimum 1.0 -maximum 100.0;
      $WHPKUnitCost=get-random -minimum 1 -maximum 100;
      $WHPKQuantity=get-random -minimum 1 -maximum 100;
      $WHPKWeight=get-random -minimum 10 -maximum 100;
       [DateTime]$theMin = "1/1/2008";
    [DateTime]$theMax = [DateTime]::Now;
    $theRandomGen = new-object random;
    $theRandomTicks = [Convert]::ToInt64( ($theMax.ticks * 1.0 - $theMin.Ticks * 1.0 ) * $theRandomGen.NextDouble() + $theMin.Ticks * 1.0 );
    $Date=new-object DateTime($theRandomTicks);
    $EffStartDate=Get-Date $Date -Format 'yyyy-MM-dd';
    $theMin=$Date;
    $theRandomGen = new-object random;
    $theRandomTicks = [Convert]::ToInt64( ($theMax.ticks * 1.0 - $theMin.Ticks * 1.0 ) * $theRandomGen.NextDouble() + $theMin.Ticks * 1.0 );
    $Date=new-object DateTime($theRandomTicks);
    $EffEndDate=Get-Date $Date -Format 'yyyy-MM-dd';
    $ItemStatus=get-random $Status -count 1;
    $SourceFlag=get-random $Flag -count 1;
    $ProductType=get-random $Type -count 1;
    $StartWeekHash.Set_Item($ItemInd,$EffStartDate);
    $EndWeekHash.Set_Item($ItemInd,$EffEndDate);
    $EffectiveWeek[$ItemInd,0]=$EffStartDate;
     $EffectiveWeek[$ItemInd,1]=$EffEndDate;
      $ItemFile.writeline($OptCompany+","+$MerchZoneNo+","+$MerchZoneName+","+$DeptNo+","+$DeptName+","+$CatGroupNo+","+$CatGroupName+","+$CatNo+","+$CatName+","+$SubCatNo+","+$SubCatName+","+$FineLineNo+","+$FineLineName+","+$CID+","+$StyleNo+","+$StyleDesc+","+$StyleColorNo+","+$StyleColorDesc+","+$ItemNo+","+$ItemName+","+$VendorName+","+$VendorNo+","+$VendorNo9+","+$Network+","+$FlowPolIDC+","+$FlowPolRDC+","+$BreakPack+","+$ItemConv+","+$BaseUnitRetail+","+$UnitCost+","+$ItemWeight+","+$ItemLength+","+$ItemHeight+","+$ItemWidth+","+$VNPKLength+","+$VNPKWidth+","+$VNPKHeight+","+$VNPKWeight+","+$VNPKCost+","+$VNPKQuantity+","+$WHPKLength+","+$WHPKWidth+","+$WHPKHeight+","+$WHPKWeight+","+$WHPKUnitCost+","+$WHPKQuantity+","+$EffStartDate+","+$EffEndDate+","+$ItemStatus+","+$SourceFlag+","+$ProductType);
	}
	$ItemFile.close();
}
function generateCalendar{
	param([DateTime]$StartDate,$Years);
	$QuarterHash=@{3="1";4="1";5="1";6="2";7="2";8="2";9="3";10="3";11="3";12="4";1="4";2="4"};
	[DateTime]$SDate=get-date $StartDate;
	[DateTime]$EndDate=$SDate.AddYears($Years);
	$TimeFile = [System.IO.StreamWriter] ("$OutputDirectory\Calendar.csv");
	$TimeFile.writeline("Year,Quarter No,Month No,4_5_4 Month,Month Name,4_5_4 Week No,Week No,Day No,Day Name,Date");
	$WeekCount=6;
	write-host "SDate before Loop"+$SDate;
	while($SDate -lt $EndDate)
	{  
	   $WeekCount=$WeekCount+1;
	   $MonthName=get-date $SDate -format "M";
	   $MonthName=$MonthName.split(" ")[0];
       $WeekCnt=[math]::floor($WeekCount/7);
       #write-host $SDate.Month;
       #write-host $QuarterHash.Get_Item($SDate.Month);
       $date=get-date $SDate -format "yyyy-MM-dd"
       $TimeFile.writeline($SDate.Year.ToString()+","+$QuarterHash.Get_Item($SDate.Month)+","+$SDate.Month+","+$SDate.Month+","+$MonthName+","+$WeekCnt+","+$WeekCnt+","+$SDate.Day+","+$SDate.DayofWeek+","+$date);
       $SDate=$SDate.AddDays(1);
	}
	$script:Weeks=$WeekCnt;
	$TimeFile.close();

}
function getParameter {
  param ($default, $paramname);
  if("true" -eq $usesettingsfile)
  {
    $content = get-childitem $settingsfile | get-content;
    $newcontent = -join ($content);
    $settings = $newcontent | select-xml "Settings/Setting[@id='$paramname']";
    if(!$settings)
    {
      write-host "$paramname not specified, defaults to: $default";
      $script:functionreturn = $default;
    }
    else
    {
      $settings = foreach ($setting in $settings) { -join ($setting, ""); };
      $settingstring = convertListToString $settinglist;
      write-host "$paramname specified by settings file: $settings";
      $script:functionreturn = $settings;
    }
  }
  else
  {
    write-host "$paramname not specified, defaults to: $default";
    $script:functionreturn = $default;
  }
}

function loadParameters {
  if(!$SettingsFile)
  {
    "No Settings file specified";
    $script:usesettingsfile = "false";
  }
  else
  {
    "Settings file specified as: $SettingsFile";
    $parent = split-path $SettingsFile -parent;



    if (!$parent)
    {
      $parent = get-location;
    }

    if (!(test-path $SettingsFile))
    {
      write-host "Warning: can't find settings file $SettingsFile" -ForegroundColor Yellow;
      $script:usesettingsfile = "false";
    }
    else
    {
      $script:usesettingsfile = "true";
    }
  }

  if (!$OutputDirectory)
  {
    $functionresult = getParameter "C:\Temp\psr-scs-data" "OutputDirectory";
    $functionresult;
    $script:OutputDirectory = $functionreturn;
  }
  else
  {
    write-host "OutputDirectory specified by command line: $OutputDirectory";
  }

  if (!(test-path $OutputDirectory))
  {
    new-item -type directory -path $OutputDirectory > null;
  }
  $script:OutputDirectory = -join ("", (resolve-path $OutputDirectory));

  
  if (!$NumberDCs)
  {
    $functionresult = getParameter "5" "NumberDCs";
    $functionresult;
    $script:NumberDCs = toInteger $functionreturn;
  }
  else
  {
    write-host "NumberDCs specified by command line: $NumberDCs";
  }
  if (!$StoreCount)
  {
    $functionresult = getParameter "100" "StoreCount";
    $functionresult;
    $script:StoreCount = toInteger $functionreturn;
  }
  else
  {
    write-host "StoreCount specified by command line: $StoreCount";
  }
  if (!$ItemCount)
  {
    $functionresult = getParameter "100" "ItemCount";
    $functionresult;
    $script:ItemCount = toInteger $functionreturn;
  }
  else
  {
    write-host "ItemCount specified by command line: $ItemCount";
  }
   if (!$StartDate)
  {
    $functionresult = getParameter "100" "StartDate";
    $functionresult;
    $script:StartDate = [DateTime] $functionreturn;
  }
  else
  {
    write-host "StartDate specified by command line: $StartDate";
  }
if (!$Years)
  {
    $functionresult = getParameter "100" "Years";
    $functionresult;
    $script:Years = toInteger $functionreturn;
  }
  else
  {
    write-host "Years specified by command line: $Years";
  }
  if (!$Slices)
  {
    $functionresult = getParameter "100" "Slices";
    $functionresult;
    $script:Slices = toInteger $functionreturn;
  }
  else
  {
    write-host "Slices specified by command line: $Slices";
  }
}

function convertListToString {
  param ($listvar);
  $liststring = "";
  $listcounter = 0;
  foreach ($listelem in $listvar) 
  {
    if ($listcounter -eq 0)
    {
      $liststring = -join ($listelem, "");
    }
    else
    {
      $liststring = -join ($liststring, ",", $listelem);
    }
    $listcounter = $listcounter + 1;
  }
  $liststring;
}
function toInteger {
  param ($numstring);
  try
  {
    [convert]::ToInt32(-join("", $numstring));
  }
  catch
  {
    write-host "Error converting '$numstring' to integer: $_.Exception.Message";
    0;
  }
} 

#Main Function Call

generateDataMain; 