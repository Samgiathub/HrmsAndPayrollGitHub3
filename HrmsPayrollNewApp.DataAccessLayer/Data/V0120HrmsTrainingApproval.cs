using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0120HrmsTrainingApproval
{
    public decimal TrainingAprId { get; set; }

    public decimal TrainingAppId { get; set; }

    public decimal? LoginId { get; set; }

    public decimal? TrainingId { get; set; }

    public DateTime? TrainingDate { get; set; }

    public string? Place { get; set; }

    public string? Faculty { get; set; }

    public decimal? TrainingProId { get; set; }

    public string? Description { get; set; }

    public decimal? TrainingCost { get; set; }

    public decimal? TrainingCostPerEmp { get; set; }

    public int? AprStatus { get; set; }

    public decimal CmpId { get; set; }

    public DateTime? TrainingEndDate { get; set; }

    public decimal? TrainingType { get; set; }

    public int? TrainingLeaveType { get; set; }

    public int? NoOfDay { get; set; }

    public int? ImpactSalary { get; set; }

    public int? EmpFeedback { get; set; }

    public int? SupFeedback { get; set; }

    public string? TrainingName { get; set; }

    public string? ProviderName { get; set; }

    public string? ProviderEmail { get; set; }

    public string? Type { get; set; }

    public string LeaveType { get; set; } = null!;

    public string SalaryImpact { get; set; } = null!;

    public string AprStatusName { get; set; } = null!;

    public string? CmpAddress { get; set; }

    public string? CmpName { get; set; }

    public string? Comments { get; set; }

    public string? BranchId { get; set; }

    public string? DesigId { get; set; }

    public string? GrdId { get; set; }

    public decimal? SkillId { get; set; }

    public decimal? EmpId { get; set; }

    public string? EmpFirstName { get; set; }

    public decimal? EmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public string? SkillName { get; set; }

    public string? TrainingCode { get; set; }

    public string? TrainingFromTime { get; set; }

    public string? TrainingToTime { get; set; }

    public string? DeptId { get; set; }

    public string? DeptName { get; set; }

    public byte Lock { get; set; }

    public string? DesigName { get; set; }

    public string? BranchName { get; set; }

    public string? GrdName { get; set; }

    public int BondMonth { get; set; }

    public string? Attachment { get; set; }

    public byte? PublishTraining { get; set; }

    public int? ManagerFeedbackDays { get; set; }

    public string? VideoUrl { get; set; }

    public decimal Latitude { get; set; }

    public decimal Longitude { get; set; }

    public decimal TrainingCategoryId { get; set; }

    public string CategoryId { get; set; } = null!;

    public string? TrainingCordinator { get; set; }

    public string? TrainingDirector { get; set; }
}
