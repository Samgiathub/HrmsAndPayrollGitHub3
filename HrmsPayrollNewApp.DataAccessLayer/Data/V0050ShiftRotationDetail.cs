using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0050ShiftRotationDetail
{
    public decimal ShiftTranId { get; set; }

    public decimal RotationId { get; set; }

    public decimal ShiftId { get; set; }

    public int SortId { get; set; }

    public string ShiftName { get; set; } = null!;

    public string ShiftStTime { get; set; } = null!;

    public string ShiftEndTime { get; set; } = null!;
}
