using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040HrmsOtherAssessmentMaster
{
    public decimal OaId { get; set; }

    public decimal CmpId { get; set; }

    public string? OaTitle { get; set; }

    public int? OaSort { get; set; }

    public virtual ICollection<T0050HrmsEmpOaFeedback> T0050HrmsEmpOaFeedbacks { get; set; } = new List<T0050HrmsEmpOaFeedback>();
}
