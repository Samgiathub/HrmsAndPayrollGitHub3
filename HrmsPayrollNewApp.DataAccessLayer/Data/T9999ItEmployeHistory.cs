using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T9999ItEmployeHistory
{
    public decimal TranId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? ItId { get; set; }

    public string? ItName { get; set; }

    public string? FinancialYear { get; set; }

    public decimal? LoginId { get; set; }

    public DateTime? ForDate { get; set; }

    public decimal? Amount { get; set; }

    public decimal? AmountEss { get; set; }

    public string? Details1 { get; set; }

    public string? Details2 { get; set; }

    public string? Details3 { get; set; }

    public string? Comments { get; set; }

    public decimal? Flag { get; set; }

    public DateTime SystemDate { get; set; }

    public byte IsVerified { get; set; }
}
