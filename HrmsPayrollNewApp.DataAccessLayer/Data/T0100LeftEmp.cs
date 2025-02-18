using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100LeftEmp
{
    public decimal LeftId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public DateTime LeftDate { get; set; }

    public string LeftReason { get; set; } = null!;

    public string? NewEmployer { get; set; }

    public DateTime? RegAcceptDate { get; set; }

    public byte? IsTerminate { get; set; }

    public decimal? UniformReturn { get; set; }

    public decimal? ExitInterview { get; set; }

    public decimal? NoticePeriod { get; set; }

    public byte? IsDeath { get; set; }

    public DateTime? RegDate { get; set; }

    public byte IsFnFApplicable { get; set; }

    public decimal? RptManagerId { get; set; }

    public decimal IsRetire { get; set; }

    public string? LeftReasonValue { get; set; }

    public string? LeftReasonText { get; set; }

    public decimal RequestAprId { get; set; }

    public int? ResId { get; set; }

    public byte IsAbsconded { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual ICollection<T0110EmpLeftJoinTran> T0110EmpLeftJoinTrans { get; set; } = new List<T0110EmpLeftJoinTran>();
}
