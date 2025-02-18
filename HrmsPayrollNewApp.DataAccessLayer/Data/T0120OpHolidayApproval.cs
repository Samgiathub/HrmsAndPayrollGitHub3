using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0120OpHolidayApproval
{
    public decimal OpHolidayAprId { get; set; }

    public decimal OpHolidayAppId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal HdayId { get; set; }

    public decimal? SEmpId { get; set; }

    public DateTime OpHolidayAprDate { get; set; }

    public string OpHolidayAprStatus { get; set; } = null!;

    public string? OpHolidayAprComments { get; set; }

    public decimal CreatedBy { get; set; }

    public DateTime DateCreated { get; set; }

    public decimal? ModifyBy { get; set; }

    public DateTime? DateModified { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0040HolidayMaster Hday { get; set; } = null!;

    public virtual T0100OpHolidayApplication OpHolidayApp { get; set; } = null!;

    public virtual T0080EmpMaster? SEmp { get; set; }
}
