using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0120LoanFinalNLevelApproval
{
    public string? LoanName { get; set; }

    public decimal EmpId { get; set; }

    public decimal? EmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public decimal CmpId { get; set; }

    public string? LoanStatus { get; set; }

    public decimal? LoanAppId { get; set; }

    public decimal? LoanAprId { get; set; }

    public DateTime ApplicationDate { get; set; }

    public string? AlphaEmpCode { get; set; }

    public decimal LoanId { get; set; }

    public string? LoanAppCode { get; set; }

    public decimal LoanAppAmount { get; set; }

    public decimal LoanAprAmount { get; set; }

    public string? EmpFirstName { get; set; }

    public int IsFinalApproved { get; set; }

    public decimal SEmpIdA { get; set; }

    public DateTime LoanAppDate { get; set; }
}
