using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100OpHolidayApplication
{
    public decimal OpHolidayAppId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal HdayId { get; set; }

    public DateTime OpHolidayDate { get; set; }

    public string OpHolidayStatus { get; set; } = null!;

    public string? OpHolidayComment { get; set; }

    public decimal CreatedBy { get; set; }

    public DateTime DateCreated { get; set; }

    public decimal? ModifyBy { get; set; }

    public DateTime? DateModified { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0040HolidayMaster Hday { get; set; } = null!;

    public virtual ICollection<T0120OpHolidayApproval> T0120OpHolidayApprovals { get; set; } = new List<T0120OpHolidayApproval>();
}
