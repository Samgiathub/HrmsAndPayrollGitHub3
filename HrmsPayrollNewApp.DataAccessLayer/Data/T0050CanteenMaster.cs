using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050CanteenMaster
{
    public decimal CmpId { get; set; }

    public decimal CntId { get; set; }

    public string CntName { get; set; } = null!;

    public string? FromTime { get; set; }

    public string? ToTime { get; set; }

    public DateTime? SystemDate { get; set; }

    public decimal? IpId { get; set; }

    public string? CanteenImage { get; set; }

    public int? CanteenGroup { get; set; }

    public decimal? GstPercentage { get; set; }

    public string? CutOffTime { get; set; }

    public int? IsActive { get; set; }
}
