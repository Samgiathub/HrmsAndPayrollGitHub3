using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050AssignVerticalSubVertical
{
    public int TranId { get; set; }

    public int? CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public string? VerticalId { get; set; }

    public int? UserId { get; set; }
}
