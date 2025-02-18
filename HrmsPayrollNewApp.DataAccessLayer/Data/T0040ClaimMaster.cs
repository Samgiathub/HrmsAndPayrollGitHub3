using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040ClaimMaster
{
    public decimal ClaimId { get; set; }

    public decimal CmpId { get; set; }

    public string ClaimName { get; set; } = null!;

    public decimal ClaimMaxLimit { get; set; }

    public decimal DesigWiseLimit { get; set; }

    public decimal? ClaimAprDeductFromSal { get; set; }

    public decimal? GradeWiseLimit { get; set; }

    public decimal? BranchWiseLimit { get; set; }

    public byte? ClaimLimitType { get; set; }

    public byte? ClaimType { get; set; }

    public bool? AttachMandatory { get; set; }

    public byte ClaimAllowBeyondLimit { get; set; }

    public byte BeyondMaxLimitDeductInSalary { get; set; }

    public decimal NoOfYearLimit { get; set; }

    public byte ClaimForFnf { get; set; }

    public byte GenderWise { get; set; }

    public string? ForGender { get; set; }

    public byte BasicSalaryWise { get; set; }

    public byte GrossSalaryWise { get; set; }

    public byte ApplicableOnce { get; set; }

    public int? ClaimDefId { get; set; }

    public string? ClaimTermsCondition { get; set; }

    public int? YearBy { get; set; }

    public int? ClaimMainType { get; set; }

    public int? ClaimFor { get; set; }

    public int? ClaimForMonth { get; set; }

    public DateTime? ClaimFromDate { get; set; }

    public DateTime? ClaimToDate { get; set; }

    public int? AgeWiseLimit { get; set; }

    public int? UnitId { get; set; }

    public int? BillId { get; set; }

    public int? ClaimApplicableOnceBasedOnLimit { get; set; }

    public int? GradeAgeLimit { get; set; }

    public int? AfterJoiningDays { get; set; }

    public int? ClaimReportDefId { get; set; }

    public byte? Chklimitlbl { get; set; }

    public string? RelationId { get; set; }

    public int? ApplicationLimitwise { get; set; }

    public string? SortingNo { get; set; }

    public byte? ChkAutoFill { get; set; }

    public byte? ChkNec { get; set; }

    public byte? GradeCityWiseLimit { get; set; }

    public byte? DesigCityWiseLimit { get; set; }

    public byte? HqCityWiseLimit { get; set; }

    public byte? ClaimGroup { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual ICollection<T0041ClaimMaxlimitDesign> T0041ClaimMaxlimitDesigns { get; set; } = new List<T0041ClaimMaxlimitDesign>();

    public virtual ICollection<T0041ClaimMaxlimitGradeDesigCityWise> T0041ClaimMaxlimitGradeDesigCityWises { get; set; } = new List<T0041ClaimMaxlimitGradeDesigCityWise>();

    public virtual ICollection<T0120ClaimApproval> T0120ClaimApprovals { get; set; } = new List<T0120ClaimApproval>();

    public virtual ICollection<T0140ClaimTransaction> T0140ClaimTransactions { get; set; } = new List<T0140ClaimTransaction>();
}
