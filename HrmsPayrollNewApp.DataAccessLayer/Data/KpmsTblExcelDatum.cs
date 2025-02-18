using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class KpmsTblExcelDatum
{
    public string? Section { get; set; }

    public string? Goal { get; set; }

    public string? SubGoal { get; set; }

    public string? DependedOn { get; set; }

    public string? DependedType { get; set; }

    public string? Type { get; set; }

    public string? AnnualLevel1G1 { get; set; }

    public string? AnnualLevel2G1 { get; set; }

    public string? AnnualLevel3G1 { get; set; }

    public string? SlabLevel1G2 { get; set; }

    public string? SlabLevel2G2 { get; set; }

    public string? SlabLevel3G2 { get; set; }

    public string? Target { get; set; }
}
