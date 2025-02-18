using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040HrmsRProcessMaster
{
    public decimal ProcessId { get; set; }

    public string ProcessName { get; set; } = null!;

    public string? ProcessDesc { get; set; }

    public decimal CmpId { get; set; }

    public virtual ICollection<T0040HrmsGeneralSetting> T0040HrmsGeneralSettings { get; set; } = new List<T0040HrmsGeneralSetting>();

    public virtual ICollection<T0045HrmsRProcessTemplate> T0045HrmsRProcessTemplates { get; set; } = new List<T0045HrmsRProcessTemplate>();

    public virtual ICollection<T0055InterviewProcessDetail> T0055InterviewProcessDetails { get; set; } = new List<T0055InterviewProcessDetail>();

    public virtual ICollection<T0055InterviewProcessQuestionDetail> T0055InterviewProcessQuestionDetails { get; set; } = new List<T0055InterviewProcessQuestionDetail>();
}
