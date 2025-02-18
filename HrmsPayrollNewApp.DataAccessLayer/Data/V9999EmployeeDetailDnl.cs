using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V9999EmployeeDetailDnl
{
    public string? EmpNo { get; set; }

    public string? EmpName { get; set; }

    public string? Gender { get; set; }

    public string? EmailId { get; set; }

    public string SupervisorNo { get; set; } = null!;

    public string? PaymentMode { get; set; }

    public string? BankCode { get; set; }

    public string? BankName { get; set; }

    public string? BankBranchName { get; set; }

    public string? BankAcid { get; set; }

    public string? BankIfsc { get; set; }

    public string? CategoryCader { get; set; }
}
