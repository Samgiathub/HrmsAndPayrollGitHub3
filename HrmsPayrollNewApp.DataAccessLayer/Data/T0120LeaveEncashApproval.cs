using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0120LeaveEncashApproval
{
    public decimal LvEncashAprId { get; set; }

    public decimal? LvEncashAppId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal LeaveId { get; set; }

    public string LvEncashAprCode { get; set; } = null!;

    public DateTime LvEncashAprDate { get; set; }

    public decimal? LvEncashAprDays { get; set; }

    public string LvEncashAprStatus { get; set; } = null!;

    public string LvEncashAprComments { get; set; } = null!;

    public decimal LoginId { get; set; }

    public DateTime SystemDate { get; set; }

    public byte? IsFnf { get; set; }

    public byte? EffInSalary { get; set; }

    public DateTime? UptoDate { get; set; }

    public string? LeaveCompOffDates { get; set; }

    public decimal LeaveEncashAmount { get; set; }

    public decimal? LeaveRecover { get; set; }

    public byte IsTaxFree { get; set; }

    public decimal? DaySalary { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0040LeaveMaster Leave { get; set; } = null!;

    public virtual T0100LeaveEncashApplication? LvEncashApp { get; set; }
}
