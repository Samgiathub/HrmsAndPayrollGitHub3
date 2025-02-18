using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040MasterCostCenter
{
    public decimal CostSlabId { get; set; }

    public decimal? CmpId { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public string? Bandid { get; set; }

    public string? BusinessSegment { get; set; }

    public string? CostCenterId { get; set; }

    public string? CostCenterPercentage { get; set; }

    public string? CostSlabName { get; set; }
}
