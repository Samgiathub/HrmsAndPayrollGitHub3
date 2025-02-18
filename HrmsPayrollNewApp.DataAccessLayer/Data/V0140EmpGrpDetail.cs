using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0140EmpGrpDetail
{
    public int TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal TravelApprovalId { get; set; }

    public decimal TravelApplicationId { get; set; }

    public decimal BranchId { get; set; }

    public DateTime ModifyDate { get; set; }

    public decimal SelectedEmpId { get; set; }

    public string EmpFirstName { get; set; } = null!;

    public string? BranchName { get; set; }

    public string? EmpFullName { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? WorkEmail { get; set; }
}
