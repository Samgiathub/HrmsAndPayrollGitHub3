using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0100HrmsTrainingApplication
{
    public decimal TrainingAppId { get; set; }

    public decimal? TrainingId { get; set; }

    public string? TrainingDesc { get; set; }

    public DateTime? ForDate { get; set; }

    public decimal? PostedEmpId { get; set; }

    public decimal? SkillId { get; set; }

    public int? AppStatus { get; set; }

    public decimal CmpId { get; set; }

    public decimal? LoginId { get; set; }

    public DateTime? SystemDate { get; set; }

    public byte TrainingPlan { get; set; }

    public string? SkillName { get; set; }

    public string? TrainingName { get; set; }

    public string? TrainingDescription { get; set; }

    public decimal? BranchId { get; set; }

    public decimal? GrdId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? DesigId { get; set; }

    public decimal? EmpCode { get; set; }

    public string? EmpFirstName { get; set; }

    public string? EmpFullName { get; set; }

    public string? DeptName { get; set; }

    public string? BranchName { get; set; }

    public string? GrdName { get; set; }

    public string? DesigName { get; set; }

    public decimal? EmpId { get; set; }

    public decimal TrainingCategoryId { get; set; }

    public decimal? CategoryId { get; set; }
}
