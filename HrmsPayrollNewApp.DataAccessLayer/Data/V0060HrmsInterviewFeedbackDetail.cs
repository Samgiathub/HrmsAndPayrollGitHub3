using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0060HrmsInterviewFeedbackDetail
{
    public string? QueDetail { get; set; }

    public int? IsTitle { get; set; }

    public int? IsDescription { get; set; }

    public int? IsRaiting { get; set; }

    public int? IsDynamic { get; set; }

    public int? DisNo { get; set; }

    public decimal? ProcessId { get; set; }

    public decimal FeedbackDetailId { get; set; }

    public decimal? InterviewScheduleId { get; set; }

    public decimal? LoginId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? RecPostId { get; set; }

    public decimal ProcessQId { get; set; }

    public string? Description { get; set; }

    public decimal? Rating { get; set; }

    public string? LoginName { get; set; }

    public string? EmpFullName { get; set; }

    public string? ApproveBy { get; set; }
}
