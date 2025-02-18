using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0095EmpCompanyTransfer
{
    public decimal? TranId { get; set; }

    public decimal? NewEmpId { get; set; }

    public decimal? NewCmpId { get; set; }

    public decimal? NewBranchId { get; set; }

    public decimal? NewCatId { get; set; }

    public decimal? NewGrdId { get; set; }

    public decimal? NewDeptId { get; set; }

    public decimal? NewDesigId { get; set; }

    public decimal? NewTypeId { get; set; }

    public decimal? NewShiftId { get; set; }

    public decimal? NewClientId { get; set; }

    public decimal? NewEmpMngrId { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public decimal? OldEmpId { get; set; }

    public decimal NewBasicSalary { get; set; }

    public decimal NewGrossSalary { get; set; }

    public decimal NewCtc { get; set; }

    public decimal OldBasicSalary { get; set; }

    public decimal OldGrossSalary { get; set; }

    public decimal OldCtc { get; set; }

    public string? NewEmpWeekOffDay { get; set; }

    public decimal? NewPrivilegeId { get; set; }

    public decimal? OldPrivilegeId { get; set; }

    public decimal? NewSubVerticalId { get; set; }

    public decimal? NewSegmentId { get; set; }

    public decimal? NewSubBranchId { get; set; }

    public decimal? NewSalCycleId { get; set; }

    public string? NewLoginAlias { get; set; }

    public string? OldLoginAlias { get; set; }

    public decimal? ReplaceManagerCmpId { get; set; }

    public decimal? ReplaceManagerId { get; set; }
}
