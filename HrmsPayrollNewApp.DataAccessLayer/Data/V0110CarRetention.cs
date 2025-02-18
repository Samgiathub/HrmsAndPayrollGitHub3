using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0110CarRetention
{
    public string AdName { get; set; } = null!;

    public decimal? AdId { get; set; }

    public decimal? AdAmount { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public decimal NoOfMonth { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal TranId { get; set; }
}
