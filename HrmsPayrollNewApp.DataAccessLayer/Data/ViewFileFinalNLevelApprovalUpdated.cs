using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class ViewFileFinalNLevelApprovalUpdated
{
    public decimal? CmpId { get; set; }

    public decimal FileAppId { get; set; }

    public decimal? EmpId { get; set; }

    public string? ApplicationDate { get; set; }

    public decimal FaId { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public string? EmpFirstName { get; set; }

    public string FileNumber { get; set; } = null!;

    public string Subject { get; set; } = null!;

    public string Description { get; set; } = null!;

    public decimal? FTypeId { get; set; }

    public int? AprStatus { get; set; }

    public string? Status { get; set; }

    public decimal? ForwardEmpId { get; set; }

    public decimal? SubmitEmpId { get; set; }

    public decimal SEmpIdA { get; set; }

    public decimal SEmpId { get; set; }

    public int? FStatusId { get; set; }

    public byte RptLevel { get; set; }

    public string? ApprovalComments { get; set; }

    public decimal TranId { get; set; }

    public decimal SchemeId { get; set; }

    public decimal? UpdatedbyEmp { get; set; }

    public decimal? ReviewEmpId { get; set; }

    public decimal? ReviewedByEmpId { get; set; }

    public string FileAppDoc { get; set; } = null!;
}
