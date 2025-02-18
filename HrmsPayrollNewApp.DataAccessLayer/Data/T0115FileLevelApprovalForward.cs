using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0115FileLevelApprovalForward
{
    public int FwDetailId { get; set; }

    public decimal TranId { get; set; }

    public DateTime ApproveDate { get; set; }

    public decimal FileAprId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? FileAppId { get; set; }

    public decimal EmpId { get; set; }

    public string FileNumber { get; set; } = null!;

    public int? FStatusId { get; set; }

    public decimal? FTypeId { get; set; }

    public string? Subject { get; set; }

    public string? Description { get; set; }

    public DateTime? ProcessDate { get; set; }

    public string? FileAppDoc { get; set; }

    public decimal? ForwardEmpId { get; set; }

    public decimal? SubmitEmpId { get; set; }

    public string? ApprovalComments { get; set; }

    public decimal? SEmpId { get; set; }

    public byte RptLevel { get; set; }

    public DateTime SystemDate { get; set; }

    public string? UserId { get; set; }

    public decimal? ReviewEmpId { get; set; }

    public decimal? ReviewedByEmpId { get; set; }

    public string? UpdatedUserId { get; set; }

    public string? FileTypeNumber { get; set; }
}
