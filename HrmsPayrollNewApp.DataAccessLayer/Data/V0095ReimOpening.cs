using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0095ReimOpening
{
    public decimal ReimOpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal RcId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal? ReimOpeningAmount { get; set; }

    public string? EmpFullName { get; set; }

    public string? AlphaCode { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? AdName { get; set; }
}
