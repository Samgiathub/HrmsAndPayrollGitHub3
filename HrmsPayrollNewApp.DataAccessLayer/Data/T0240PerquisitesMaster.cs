using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0240PerquisitesMaster
{
    public decimal PerquisitesId { get; set; }

    public decimal CmpId { get; set; }

    public string Name { get; set; } = null!;

    public string SortName { get; set; } = null!;

    public decimal SortingNo { get; set; }

    public decimal DefId { get; set; }

    public string? Remarks { get; set; }
}
