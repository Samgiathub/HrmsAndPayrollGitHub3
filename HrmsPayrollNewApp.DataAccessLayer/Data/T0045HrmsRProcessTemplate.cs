using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0045HrmsRProcessTemplate
{
    public decimal ProcessQId { get; set; }

    public decimal CmpId { get; set; }

    public decimal ProcessId { get; set; }

    public string? QueDetail { get; set; }

    public int? IsTitle { get; set; }

    public int? IsDescription { get; set; }

    public int? IsRaiting { get; set; }

    public int? IsDynamic { get; set; }

    public int? DisNo { get; set; }

    public int? QuestionType { get; set; }

    public string? QuestionOption { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0040HrmsRProcessMaster Process { get; set; } = null!;

    public virtual ICollection<T0055InterviewProcessQuestionDetail> T0055InterviewProcessQuestionDetails { get; set; } = new List<T0055InterviewProcessQuestionDetail>();

    public virtual ICollection<T0060HrmsInterviewFeedbackDetail> T0060HrmsInterviewFeedbackDetails { get; set; } = new List<T0060HrmsInterviewFeedbackDetail>();
}
