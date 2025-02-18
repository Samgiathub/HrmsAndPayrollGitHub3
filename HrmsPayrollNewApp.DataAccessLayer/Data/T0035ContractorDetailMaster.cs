using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0035ContractorDetailMaster
{
    public decimal ContrDetId { get; set; }

    public decimal? BranchId { get; set; }

    public string? ContrPersonName { get; set; }

    public string? ContrEmail { get; set; }

    public string? ContrMobileNo { get; set; }

    public string? ContrAadhaar { get; set; }

    public string? ContrGstnumber { get; set; }

    public string? NatureOfWork { get; set; }

    public decimal? NoOfLabourEmployed { get; set; }

    public DateTime? DateOfCommencement { get; set; }

    public DateTime? DateOfTermination { get; set; }

    public string? VendorCode { get; set; }

    public string? LicenceDoc { get; set; }

    public virtual T0030BranchMaster? Branch { get; set; }
}
