using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040SlabCostCenter
{
    public decimal SlabId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? SlabFrom { get; set; }

    public decimal? SlabTo { get; set; }

    public string? SlabName { get; set; }
}
