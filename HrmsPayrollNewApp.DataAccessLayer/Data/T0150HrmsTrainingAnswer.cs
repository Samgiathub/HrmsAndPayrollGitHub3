using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0150HrmsTrainingAnswer
{
    public decimal TranAnswerId { get; set; }

    public decimal? TranFeedbackId { get; set; }

    public decimal? TranEmpDetailId { get; set; }

    public decimal TranQuestionId { get; set; }

    public string Answer { get; set; } = null!;

    public decimal CmpId { get; set; }

    public DateTime CreateDate { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? TrainingId { get; set; }

    public decimal? TrainingAprId { get; set; }

    public decimal? TrainingInductionId { get; set; }

    public virtual T0080EmpMaster? Emp { get; set; }

    public virtual T0040HrmsTrainingMaster? Training { get; set; }

    public virtual T0120HrmsTrainingApproval? TrainingApr { get; set; }

    public virtual T0150HrmsTrainingQuestionnaire TranQuestion { get; set; } = null!;
}
