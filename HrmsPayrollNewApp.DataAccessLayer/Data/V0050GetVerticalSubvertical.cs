using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0050GetVerticalSubvertical
{
    public int TranId { get; set; }

    public int? CmpId { get; set; }

    public decimal EmpId { get; set; }

    public string? EmpFullName { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public string? VerticalId { get; set; }

    public string? Vertical { get; set; }
}
