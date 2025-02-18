using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0055HrmsInterviewScheduleHistory
{
    public decimal InterviewScheduleHistoryId { get; set; }

    public decimal? InterviewProcessDetailId { get; set; }

    public decimal CmpId { get; set; }

    public decimal RecPostId { get; set; }

    public decimal ResumeId { get; set; }

    public decimal? SEmpId { get; set; }

    public decimal? SEmpId2 { get; set; }

    public decimal? SEmpId3 { get; set; }

    public decimal? SEmpId4 { get; set; }

    public DateTime? FromDate { get; set; }

    public DateTime? ToDate { get; set; }

    public string? FromTime { get; set; }

    public string? ToTime { get; set; }

    public byte? BypassInterview { get; set; }

    public DateTime SystemDate { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0055InterviewProcessDetail? InterviewProcessDetail { get; set; }

    public virtual T0052HrmsPostedRecruitment RecPost { get; set; } = null!;

    public virtual T0055ResumeMaster Resume { get; set; } = null!;

    public virtual T0080EmpMaster? SEmp { get; set; }
}
