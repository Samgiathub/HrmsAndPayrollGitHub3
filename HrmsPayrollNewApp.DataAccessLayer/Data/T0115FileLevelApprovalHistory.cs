using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0115FileLevelApprovalHistory
{
    public int FhId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? FileAppId { get; set; }

    public decimal? FileAprId { get; set; }

    public decimal EmpId { get; set; }

    public string HFileNumber { get; set; } = null!;

    public int? HFStatusId { get; set; }

    public decimal? HFTypeId { get; set; }

    public string? HSubject { get; set; }

    public string? HDescription { get; set; }

    public decimal? HSEmpId { get; set; }

    public DateTime? HProcessDate { get; set; }

    public string? HFileAppDoc { get; set; }

    public byte? RptLevel { get; set; }

    public DateTime? CreatedDate { get; set; }

    public string? UserId { get; set; }

    public string? HTransType { get; set; }

    public decimal? HTranId { get; set; }

    public string? TblType { get; set; }

    public string? HApprovalComments { get; set; }

    public decimal? HForwardEmpId { get; set; }

    public decimal? HSubmitEmpId { get; set; }

    public decimal? HReviewEmpId { get; set; }

    public decimal? HReviewedByEmpId { get; set; }

    public string? FileTypeNumber { get; set; }
}
