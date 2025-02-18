using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0095EmpCompanyTransfer
{
    public decimal TranId { get; set; }

    public decimal OldCmpId { get; set; }

    public decimal OldEmpId { get; set; }

    public decimal OldBranchId { get; set; }

    public decimal OldGrdId { get; set; }

    public decimal OldDesigId { get; set; }

    public decimal OldDeptId { get; set; }

    public decimal OldShiftId { get; set; }

    public decimal OldTypeId { get; set; }

    public decimal OldCatId { get; set; }

    public decimal OldClientId { get; set; }

    public decimal OldEmpManagerId { get; set; }

    public string? OldEmpWeekOffDay { get; set; }

    public DateTime EffectiveDate { get; set; }

    public decimal NewCmpId { get; set; }

    public decimal NewEmpId { get; set; }

    public decimal NewBranchId { get; set; }

    public decimal NewGrdId { get; set; }

    public decimal NewDesigId { get; set; }

    public decimal? NewDeptId { get; set; }

    public decimal NewShiftId { get; set; }

    public decimal? NewCatId { get; set; }

    public decimal? NewTypeId { get; set; }

    public decimal NewClientId { get; set; }

    public decimal? NewEmpMngrId { get; set; }

    public string? NewEmpWeekOffDay { get; set; }

    public decimal? OldPrivilegeId { get; set; }

    public decimal? NewPrivilegeId { get; set; }

    public decimal? NewSubVerticalId { get; set; }

    public decimal? NewSegmentId { get; set; }

    public decimal? NewSubBranchId { get; set; }

    public string? NewLoginAlias { get; set; }

    public string? OldLoginAlias { get; set; }

    public decimal? OldSubVerticalId { get; set; }

    public decimal? OldSegmentId { get; set; }

    public decimal? OldSubBranchId { get; set; }

    public decimal? NewSalCycleId { get; set; }

    public decimal? OldSalCycleId { get; set; }

    public byte IsMultiPageFlag { get; set; }

    public decimal? ReplaceManagerCmpId { get; set; }

    public decimal? ReplaceManagerId { get; set; }

    public virtual ICollection<T0100EmpCompanyAdvanceTransfer> T0100EmpCompanyAdvanceTransfers { get; set; } = new List<T0100EmpCompanyAdvanceTransfer>();

    public virtual ICollection<T0100EmpCompanyBondTransfer> T0100EmpCompanyBondTransfers { get; set; } = new List<T0100EmpCompanyBondTransfer>();

    public virtual ICollection<T0100EmpCompanyLeaveTransfer> T0100EmpCompanyLeaveTransfers { get; set; } = new List<T0100EmpCompanyLeaveTransfer>();

    public virtual ICollection<T0100EmpCompanyLoanTransfer> T0100EmpCompanyLoanTransfers { get; set; } = new List<T0100EmpCompanyLoanTransfer>();

    public virtual ICollection<T0100EmpCompanyTransferEarnDeduction> T0100EmpCompanyTransferEarnDeductions { get; set; } = new List<T0100EmpCompanyTransferEarnDeduction>();

    public virtual ICollection<T0100EmpCompanyTransferSalaryDetail> T0100EmpCompanyTransferSalaryDetails { get; set; } = new List<T0100EmpCompanyTransferSalaryDetail>();
}
