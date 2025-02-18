using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0040ClearanceAttribute
{
    public string? DeptName { get; set; }

    public decimal ClearanceId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? DeptId { get; set; }

    public string? ItemCode { get; set; }

    public string ItemName { get; set; } = null!;

    public byte Active { get; set; }

    public string? CostCenterId { get; set; }

    public string? CenterName { get; set; }

    public string StatusColor { get; set; } = null!;
}
