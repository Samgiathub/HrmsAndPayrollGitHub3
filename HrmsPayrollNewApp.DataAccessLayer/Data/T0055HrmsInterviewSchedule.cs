using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0055HrmsInterviewSchedule
{
    public decimal InterviewScheduleId { get; set; }

    public decimal? InterviewProcessDetailId { get; set; }

    public decimal RecPostId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? SEmpId { get; set; }

    public decimal? SEmpId2 { get; set; }

    public decimal? SEmpId3 { get; set; }

    public decimal? SEmpId4 { get; set; }

    public DateTime? FromDate { get; set; }

    public DateTime? ToDate { get; set; }

    public string? FromTime { get; set; }

    public string? ToTime { get; set; }

    public decimal ResumeId { get; set; }

    public decimal? Rating { get; set; }

    public decimal? Rating2 { get; set; }

    public decimal? Rating3 { get; set; }

    public decimal? Rating4 { get; set; }

    public DateTime? ScheduleDate { get; set; }

    public string? ScheduleTime { get; set; }

    public decimal? ProcessDisNo { get; set; }

    public decimal Status { get; set; }

    public string? Comments { get; set; }

    public string? Comments2 { get; set; }

    public string? Comments3 { get; set; }

    public string? Comments4 { get; set; }

    public DateTime? SystemDate { get; set; }

    public int? BypassInterview { get; set; }

    public decimal? HrDocId { get; set; }

    public decimal PaidTravelAmount { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0055InterviewProcessDetail? InterviewProcessDetail { get; set; }

    public virtual T0052HrmsPostedRecruitment RecPost { get; set; } = null!;

    public virtual T0055ResumeMaster Resume { get; set; } = null!;

    public virtual ICollection<T0060HrmsInterviewFeedbackDetail> T0060HrmsInterviewFeedbackDetails { get; set; } = new List<T0060HrmsInterviewFeedbackDetail>();
}
