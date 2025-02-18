using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040ClearanceAttribute
{
    public decimal ClearanceId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? DeptId { get; set; }

    public string? ItemCode { get; set; }

    public string ItemName { get; set; } = null!;

    public byte Active { get; set; }

    public string? CostCenterId { get; set; }
}
