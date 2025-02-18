using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100TravelApplication
{
    public decimal TravelApplicationId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal? SEmpId { get; set; }

    public DateTime ApplicationDate { get; set; }

    public string ApplicationCode { get; set; } = null!;

    public string ApplicationStatus { get; set; } = null!;

    public decimal LoginId { get; set; }

    public DateTime CreateDate { get; set; }

    public DateTime? ModifyDate { get; set; }

    public byte ChkAdv { get; set; }

    public byte ChkAgenda { get; set; }

    public string? TourAgenda { get; set; }

    public string? ImpBusinessAppoint { get; set; }

    public string? KraTour { get; set; }

    public string? AttachedDocFile { get; set; }

    public byte ChkInternational { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0080EmpMaster? SEmp { get; set; }

    public virtual ICollection<T0110TravelAdvanceDetail> T0110TravelAdvanceDetails { get; set; } = new List<T0110TravelAdvanceDetail>();

    public virtual ICollection<T0110TravelApplicationDetail> T0110TravelApplicationDetails { get; set; } = new List<T0110TravelApplicationDetail>();

    public virtual ICollection<T0115TravelLevelApproval> T0115TravelLevelApprovals { get; set; } = new List<T0115TravelLevelApproval>();

    public virtual ICollection<T0120TravelApproval> T0120TravelApprovals { get; set; } = new List<T0120TravelApproval>();
}
