using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0060HrmsInterviewFeedbackDetail
{
    public decimal FeedbackDetailId { get; set; }

    public decimal? InterviewScheduleId { get; set; }

    public decimal? LoginId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? RecPostId { get; set; }

    public decimal ProcessQId { get; set; }

    public string? Description { get; set; }

    public decimal? Rating { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0055HrmsInterviewSchedule? InterviewSchedule { get; set; }

    public virtual T0011Login? Login { get; set; }

    public virtual T0045HrmsRProcessTemplate ProcessQ { get; set; } = null!;
}
