using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0160HrmsManagerFeedbackResponse
{
    public decimal TranManagerFeedbackId { get; set; }

    public decimal CmpId { get; set; }

    public decimal TrainingAprId { get; set; }

    public decimal TrainingId { get; set; }

    public decimal EmpId { get; set; }

    public decimal TranQuestionId { get; set; }

    public string? ManagerAnswer { get; set; }

    public DateTime AnsDate { get; set; }

    public decimal FeedbackBy { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0040HrmsTrainingMaster Training { get; set; } = null!;

    public virtual T0120HrmsTrainingApproval TrainingApr { get; set; } = null!;

    public virtual T0150HrmsTrainingQuestionnaire TranQuestion { get; set; } = null!;
}
