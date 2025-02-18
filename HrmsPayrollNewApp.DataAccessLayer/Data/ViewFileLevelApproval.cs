using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class ViewFileLevelApproval
{
    public int FinalApprover { get; set; }

    public decimal FaId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal TranId { get; set; }

    public decimal? FileAppId { get; set; }

    public decimal? SEmpId { get; set; }

    public int? AprStatus { get; set; }

    public DateTime ApproveDate { get; set; }

    public decimal FileAprId { get; set; }

    public string FileNumber { get; set; } = null!;

    public string Subject { get; set; } = null!;

    public string Description { get; set; } = null!;

    public int? FStatusId { get; set; }

    public DateTime? ProcessDate { get; set; }

    public string FileAppDoc { get; set; } = null!;

    public decimal? ForwardEmpId { get; set; }

    public decimal? SubmitEmpId { get; set; }

    public string? ApprovalComments { get; set; }

    public byte RptLevel { get; set; }

    public string? Status { get; set; }

    public string? ApplicationDate { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? EmpFirstName { get; set; }

    public string? EmpFullName { get; set; }

    public decimal SchemeId { get; set; }

    public decimal? UpdatedbyEmp { get; set; }

    public decimal? ReviewEmpId { get; set; }

    public decimal? ReviewedByEmpId { get; set; }

    public string? ForwardEmployee { get; set; }

    public string? ForwardByEmployee { get; set; }

    public string? ReviewEmployee { get; set; }

    public string? ReviewByEmployee { get; set; }

    public string FileTypeNumber { get; set; } = null!;
}
