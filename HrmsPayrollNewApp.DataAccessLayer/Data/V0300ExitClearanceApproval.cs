using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0300ExitClearanceApproval
{
    public string? AlphaEmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public string? FEmpFullName { get; set; }

    public DateTime RequestDate { get; set; }

    public string NocStatus { get; set; } = null!;

    public decimal ExitId { get; set; }

    public decimal HodId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? BranchId { get; set; }

    public DateTime? ResignationDate { get; set; }

    public DateTime DateOfJoin { get; set; }

    public decimal EmpId { get; set; }

    public string Status { get; set; } = null!;

    public decimal? DesigId { get; set; }

    public decimal? DeptId { get; set; }

    public string DesigName { get; set; } = null!;

    public string? BranchName { get; set; }

    public string? DeptName { get; set; }

    public decimal? EmpSuperior { get; set; }

    public DateTime LastDate { get; set; }

    public decimal ApprovalId { get; set; }

    public string? Remarks { get; set; }

    public string? EmpLeft { get; set; }

    public decimal? Exitdeptid { get; set; }

    public string? ExitDept { get; set; }

    public string? SupAck { get; set; }

    public decimal? CenterId { get; set; }

    public string CenterName { get; set; } = null!;
}
