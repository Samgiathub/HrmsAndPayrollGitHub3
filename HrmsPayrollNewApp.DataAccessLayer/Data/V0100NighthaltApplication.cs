using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0100NighthaltApplication
{
    public decimal ApplicationId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal BranchId { get; set; }

    public DateTime FromDate { get; set; }

    public DateTime ToDate { get; set; }

    public decimal? NoOfDays { get; set; }

    public string? VisitPlace { get; set; }

    public string? Remarks { get; set; }

    public string? AppStatus { get; set; }

    public string? EmpFullName { get; set; }

    public string EmpFirstName { get; set; } = null!;

    public decimal? REmpId { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? SuperiorName { get; set; }

    public decimal? ApprovalId { get; set; }

    public decimal? ApproveDays { get; set; }

    public decimal? Amount { get; set; }

    public decimal? CalculatedAmount { get; set; }

    public decimal ApplicationCode { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public decimal? DeptId { get; set; }

    public bool AdminFlag { get; set; }
}
