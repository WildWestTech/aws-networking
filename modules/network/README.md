### Network Overview
- I'm creating multiple account: 
    - dev  
    - prod
- Each account gets its own VPC.
- Each VPC will have 3 availability zones for now.
- Each AZ will have two subnets: 1 private & 1 public.
- I'd like to keep my databases in private subnets, but still be able to access them locally, so I'll use a vpn.

### OpenVPN
- https://github.com/WildWestTech/aws-openvpn
- For now, I'll create a third, central account, specifically for installing an OpenVPN server
- I'll allow for cross-account, vpc-peering:
    - openvpn <--> dev
    - openvpn <--> prod
- Therefore, the openvpn repo/project is a pre-req for this repo.

### NAT Gateway
- Since this is for my lab, some "free" or "cheap" items will stay up.  For example, my OpenVPN server will stay up and so will most of my other networking items, like subnets and security groups.
- The NAT Gateway is required for some of my work with EMR Studio.  However, it is not required 24/7, so I will transition that file (nat-gatewat.tf) in and out of the inactive folder between lab sessions.  Hopefully this will help reduce costs.
- I'm trying to stay organized, but I'll keep the nat-gateway and mandatory, realated items in the same file.  That way it's easier to drag-and-drop to active/inactive status between terraform applies.


