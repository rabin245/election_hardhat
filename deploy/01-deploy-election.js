module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  const election = await deploy("Election", {
    from: deployer,
    args: [],
    log: true,
  });

  console.log("Election deployed to:", election.address);
};

module.exports.tag = ["all", "election"];
